class Spot < ActiveRecord::Base

  ### Includes/Requirements
  #require 'open-uri'
  #require 'rubygems'
  #require 'hpricot'
  require 'nokogiri'

  ### Behavior
  #attr_accessible :thing_id, :user_id
  
  ### Associations
  belongs_to :user, :counter_cache => true
  belongs_to :thing, :counter_cache => true
  belongs_to :store, :counter_cache => true
  belongs_to :recommended_to_user, :class_name => 'User'
  has_one :comment, :dependent => :destroy
  accepts_nested_attributes_for :thing, :comment

  ### Validations
  validates_presence_of :thing#, :website_url #website_url = recommendations won't work
  validates_presence_of :user, :message => 'not found'
  # Removed validates_uniqueness to allow multiple spots/prices/websites
  #validates_uniqueness_of :thing_id, :scope => [:user_id, :recommended_to_user_id], :message => 'already exists in user\'s feed'
  #validates_associated :thing
  #validates_acceptance_of :not_recommended_to_yourself?, :message => 'is a requirement.'

  ### Callbacks
  before_validation :clean_up_fields
  before_destroy :destroy_lonely_things
  after_create :notify_other_users
  before_save :guess_store
  
  ### Instance Methods
  
  def to_param
    return "#{self.id}-#{self.thing.name_with_brand.gsub(' ', '-').gsub(/[^a-z0-9\-]+/i, '')}".downcase
  end

  def action_verb
    # Higher up = precedence
    if self.recommended_to_user
      return 'Recommended'
    elsif self.original_spot_id
      return 'Re-spotted'
    elsif self.is_owned
      return 'Owned'
    elsif self.is_wanted
      return 'Wishlisted'
    else
      return 'Spotted'
    end
  end
  
  def comment_text
    return self.comment.comment if self.comment
  end

  def guess_store
    if !self.website_url.blank?
      Store.all.each do |store|
        if store.url_key && self.website_url.downcase.index(Regexp.new(store.url_key.downcase, true))
          self.store = store
          #self.save(false)
          break
        end
      end
      if self.store.nil?
        # Create new Store
        self.store = Store.create_from_url(self.website_url)
      end
    end
    return self.store
  end
  
  def not_recommended_to_yourself?
    (self.user_id != self.recommended_to_user_id)
  end
  
  def recommend_to_users
    ''
  end

  def recommend_to_users=(userstr)
    #logger.debug 'RECOMMEND TO USER: ' + userstr.to_s
    return if userstr.blank?
    self.recommended_to_user = User.find(:first, :conditions => "name LIKE '#{userstr}%'")
  end

  def website_url=(value)
    if !value.blank?
      value = 'http://' + value if value.index('http').nil?
      write_attribute :website_url, value
    else
      write_attribute :website_url, nil
    end
  end
      
  def fetch_data_from_url(url)
    url = 'http://' + url if url.index('http://').nil?
    #logger.debug url

    html = Nokogiri::HTML(open(url).read)
    page_title = html.xpath('/html/head/title').children.first.to_s.strip
    page_description = ''
    # Loop through Meta tags
    html.xpath('/html/head/meta').each do |meta_tag|
      #logger.debug meta_tag.attributes.values[0].to_s + ' = ' + meta_tag.attributes.values[1].to_s
      case meta_tag.attributes.values[0].to_s
        when 'description': page_description = meta_tag.attributes.values[1]
      end
    end

    self.thing.name = page_title.strip.titleize
    self.thing.description = page_description
    #self.thing.product_page_url = url
    self.website_url = url
  end
  
  def destroy_lonely_things
    # Remove Thing if this Spot is the only one referring to it
    if (self.thing.spots.count == 1)
      self.thing.delete
    end
  end
  
  def notify_other_users
    begin
      # 1. Notify the Recommendee (if any)
      # If has a Recommendee && Recommendee.has_email
      if (self.recommended_to_user && self.recommended_to_user.can_receive_email?)
        # Send email
        Emailer.deliver_recommendation_notification(self.recommended_to_user, self)
      end
      
      # 2. Notify ALL that have spotted/commented this Thing
      email_address_array = Array.new
      # Loop through Spots
      self.thing.related_users.each do |user|
        # If Spot.User != Self.User && Spot.User.can_receive_email && Not already sent
        #logger.debug "notify_other_users: Send email to #{spot.user.name}? (#{spot.user != self.user} and #{spot.user.can_receive_email?} and #{email_address_array.index(spot.user.email).nil?})"
        if (user != self.user && user.can_receive_email? && email_address_array.index(user.email).nil?)
          # Send email
          Emailer.deliver_new_spot_notification(user, self)
          email_address_array << user.email
        end
      end
    rescue
      # Error
      logger.warn "Could not send email for spot #{self.id}."
    end
  end
  
  ### Class Methods
  
  def Spot.search(search_text = nil, conditions = nil, order = "spots.created_at desc", page = 1, per_page = 16)
    order = "spots.created_at desc" if order.nil?
    
    if search_text
      conditions = "things.name LIKE '%" + search_text + "%'" + 
        " OR things.description LIKE '%" + search_text + "%'" +
       #" OR spots.comment LIKE '%" + search_text + "%'" +
        " OR tags.name LIKE '%" + search_text + "%'" +
        " OR brands.name LIKE '%" + search_text + "%'" +
        " OR stores.name LIKE '%" + search_text + "%'" +
        " OR users.name LIKE '%" + search_text + "%'"
    end
    
    # TODO: Replace with custom SQL/find_by_sql
    # Original:
    #spots = Spot.paginate(:all, :include => [:thing, :user, :store, {:thing => :tags}, {:thing => :brand}], :group => :thing_id, :order => order, :conditions => conditions, :page => page, :per_page => per_page)
    
    # Fixed for Postgres:
    spots = Spot.paginate(:all, :include => [:thing, {:thing => :tags}, {:thing => :brand}], :joins => [:user, :store, :thing], :group => 'thing_id,things.id,users.id,spots.id', :order => order, :conditions => conditions, :page => page, :per_page => per_page)
    
    # New from Stack Overflow: http://stackoverflow.com/questions/13316122/sql-problems-when-migrating-from-mysql-to-postgresql/14124660
    #spots = Spot.find_by_sql("SELECT * FROM (SELECT DISTINCT ON (spots.id) spots.id, spots.created_at AS spots_created_at FROM spots LEFT JOIN things ON things.id = spots.thing_id WHERE (spots.recommended_to_user_id = 1 OR spots.user_id IN (1) OR things.is_featured = 't') GROUP BY thing_id, things.id, spots.id) id_list ORDER BY id_list.spots_created_at DESC LIMIT 16 OFFSET 0;")
    
    #spots = Spot.find(:all, :include => [:thing, :user, :store, {:thing => :tags}, {:thing => :brand}], :group => :thing_id, :order => order, :conditions => conditions, :limit => 20)
    
    return spots
  end


  private

    def clean_up_fields
      # HintValue texts
      if self.comment && (self.comment.comment.blank? || self.comment.comment == 'Your personal comment' || self.comment.comment == 'Comment for friend')
        self.comment = nil
      end
      if self.comment
        self.comment.thing = self.thing
        self.comment.user = self.user
        # Remote whitespaces
        self.comment.comment = self.comment.comment.strip
      end
      self.recommend_to_users = nil if self.recommend_to_users.blank?
    end
      
end