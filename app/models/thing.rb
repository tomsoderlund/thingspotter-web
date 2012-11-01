require 'open-uri'

class Thing < ActiveRecord::Base

  ### Associations
  belongs_to :user
  belongs_to :brand, :counter_cache => true
  has_many :collection_things, :dependent => :destroy
  has_many :collections, :through => :collection_things
  has_many :spots, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  
  # Has Features
  acts_as_taggable
  
  has_attached_file :photo, :styles => { :web_mini => "50x50#", :web_collection_thumb => "80x65#", :web_thumb => "170x140#", :web_big => "534x400>" }, # :web_thumb => "170x140>", :web_big => "534x400>" OR :web_thumb => "170x140#", :web_big => "534x400#"
                            # :url  => "/usercontent/productphotos/:id/:style/:basename.:extension",
                            # :path => ":rails_root/public/usercontent/productphotos/:id/:style/:basename.:extension",
                            :url  => "/usercontent/productphotos/:id/:style/:normalized_photo_file_name",
                            :path => ":rails_root/public/usercontent/productphotos/:id/:style/:normalized_photo_file_name",
                            :default_url => "/images/productphoto_unknown.png"

  ### Validations
  validates_presence_of :name
  validates_length_of :name, :within => 2..64
  #validates_uniqueness_of :name, :case_sensitive => false
  #  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 500.kilobytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  validates_presence_of :photo_remote_url, :if => :photo_url_provided?, :message => 'is invalid or inaccessible'

  #attr_accessible :email, :name
  attr_accessor :photo_url
  
  ### Callbacks
  before_validation :download_remote_photo, :if => :photo_url_provided?
  before_validation :clean_up_fields
  
  ### Instance Methods
  
  # Paperclip file rename: http://blog.wyeworks.com/2009/7/13/paperclip-file-rename
  Paperclip.interpolates :normalized_photo_file_name do |attachment, style|
    attachment.instance.normalized_photo_file_name
  end

  def normalized_photo_file_name
    "#{self.photo_file_name.gsub( /[^a-zA-Z0-9_\-\.]/, '_')}"#.downcase
  end

  def to_param
    return "#{self.id}-#{self.name_with_brand.gsub(' ', '-').gsub(/[^a-z0-9\-]+/i, '')}".downcase
  end
  
  def brand_name
    return self.brand.name if self.brand
    return ''
  end
  
  def brand_name=(value)
    if !value.blank?
      value = value.strip
      value_formatted = value
      value_formatted = value_formatted.titleize if value_formatted.length > 4
      #brand_id = Brand.find_or_create_by_name(value).id
      brand = Brand.find(:first, :conditions => ["lower(name) = ?", value.downcase]) || Brand.create(:name => value_formatted)
      self.brand = brand
    else
      self[:brand_id] = nil
    end
    return self.brand
  end
  
  def name_with_brand
    return (self.brand ? self.brand.name + ' ' : '') + self.name
  end
  
  def guess_brand
    if self.brand.nil? && !self.name.blank?
      Brand.all.each do |brand|
        if self.name.downcase.index(brand.name.downcase)
          self.brand = brand
          #self.save(false)
          break
        end
      end
    end
    return self.brand
  end

  def photo_file_name=(value)
    if !value.blank?
      write_attribute :photo_file_name, value
    end
  end
    
  def photo_path(style = :normal)
    return self.photo.url(style)
    # return '' if self.photo_file_name.nil?
    # if self.photo_file_name.index('http').nil?
    #   return self.photo.url(style)
    # else
    #   return self.photo_file_name
    # end
  end
  
  def has_photo?
    return !self.photo_file_name.nil?
  end

  def product_page_url=(value)
    if !value.blank?
      value = 'http://' + value if value.index('http://').nil?
      write_attribute :product_page_url, value
    else
      write_attribute :product_page_url, nil
    end
  end
        
  def find_spot(user, optimistic_search = false)
    return nil if user.nil?
    spot = Spot.find(:first, :conditions => ["user_id = ? AND thing_id = ?", user.id, self.id])
    if (spot.nil? && optimistic_search) # || user.is_admin
      spot = Spot.find(:first, :conditions => ["thing_id = ?", self.id])
    end
    return spot
  end
  
  def related_things
    tags_to_find = self.tag_list.join(', ')
    things_array = Thing.find_tagged_with(tags_to_find, :match_all => true) #.sample(10)
    # Too small? Try Users with ANY similar tags
    if things_array.size < 3
      things_array = things_array + Thing.find_tagged_with(tags_to_find, :match_all => false)
    end
    things_array.delete(self)
    # Randomize
    random_array = []
    for i in 1..10
      random_thing = things_array[rand(things_array.length)]
      random_array << random_thing unless random_thing.nil? || random_array.index(random_thing)
    end
    return random_array
  end
  
  def related_users
    user_array = Array.new
    
    # Users from Spots
    self.spots.each do |spot|
      user_array << spot.user if user_array.index(spot.user).nil?
      # recommended user too?
    end

    # Users from Comments
    self.comments.each do |comment|
      user_array << comment.user if user_array.index(comment.user).nil?
    end
    
    # Users from Collections
    # TODO: add Users from Collections
    
    return user_array
  end
  
  def latest_comment
    if self.comments.count > 0
      return self.comments.last
    else
      return nil
    end
  end
  
  def is_shared?(user)
    return nil if user.nil?
    return !(self.find_spot(user).nil?)
  end
    
  def is_wanted?(user)
    return nil if user.nil?
    spot = self.find_spot(user)
    return nil if spot.nil?
    return spot.is_wanted
  end
    
  def is_owned?(user)
    return nil if user.nil?
    spot = self.find_spot(user)
    return nil if spot.nil?
    return spot.is_owned
  end
  
  def toggle_shared(user, spot_id = nil)
    return nil if user.nil?
    spot = Spot.find_by_thing_id_and_user_id(self.id, user.id)
    if spot
      spot.destroy
      return false
    else
      spot = Spot.create(:user_id => user.id, :thing_id => self.id, :original_spot_id => spot_id)
      return true
    end
  end
  
  def toggle_wanted(user)
    return nil if user.nil?
    spot = Spot.find_or_create_by_thing_id_and_user_id(self.id, user.id)
    return false if spot.nil?
    spot.update_attribute(:is_wanted, !spot.is_wanted)
    return spot.is_wanted
  end

  def toggle_owned(user)
    return nil if user.nil?
    spot = Spot.find_or_create_by_thing_id_and_user_id(self.id, user.id)
    return false if spot.nil?
    spot.update_attribute(:is_owned, !spot.is_owned)
    return spot.is_owned
  end
  
  def wanted_count
    Spot.count(:conditions => ["thing_id = ? AND is_wanted = ?", self.id, true])
  end

  def owned_count
    Spot.count(:conditions => ["thing_id = ? AND is_owned = ?", self.id, true])
  end

  def recommended_count
    Spot.count(:conditions => ["thing_id = ? AND recommended_to_user_id IS NOT NULL", self.id])
  end
  
  def primary_spot
    self.spots[0]
  end

  def primary_url
    self.primary_spot.website_url
  end
  
  
  ### Class Methods

  # t.integer  "user_id"
  # t.string   "name",               :limit => 64
  # t.text     "description"
  # t.integer  "brand_id"
  # t.string   "barcode",            :limit => 16
  # t.string   "photo_file_name",    :limit => 128
  # t.string   "photo_content_type", :limit => 16
  # t.integer  "photo_file_size"
  # t.datetime "photo_updated_at"
  # t.datetime "created_at"
  # t.datetime "updated_at"
  # t.string   "photo_remote_url"
  # t.integer  "spots_count",                       :default => 0
  # t.boolean  "is_featured",                       :default => false

  
  def Thing.merge(thing_from, thing_to)
    logger.debug "Merge #{thing_from.name} --> #{thing_to.name}"
    # Thing data
    #thing_to.name
    thing_to.description = thing_from.description if thing_to.description.blank?
    thing_to.brand_id = thing_from.brand_id if thing_to.brand_id.nil?
    thing_to.is_featured = (thing_from.is_featured || thing_to.is_featured)
    thing_to.tags = thing_to.tags + thing_from.tags
    thing_to.save
    # Spots
    thing_from.spots.each do |spot|
      spot.thing = thing_to
      spot.save
    end
    # thing_to.spots_count?
    # Comments
    thing_from.comments.each do |comment|
      comment.thing = thing_to
      comment.save
    end
    # Collections
    thing_from.collection_things.each do |collection_thing|
      collection_thing.thing = thing_to
      collection_thing.save
    end
    # Delete old thing
    #thing_from.destroy
    return thing_to
  end

private

  def clean_up_fields
    # HintValue texts
    self.name = nil if self.name == 'Thing Title'
    self.description = nil if (self.description.blank? || self.description == 'Product description and features')
    # Remote whitespaces
    self.name = self.name.strip if self.name
    self.description = self.description.strip if self.description
  end
  
  def photo_url_provided?
    !self.photo_url.blank?
  end
  
  def download_remote_photo
    self.photo = do_download_remote_photo
    self.photo_remote_url = photo_url
  end
  
  def do_download_remote_photo
    io = open(URI.parse(photo_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  #rescue # catch URL errors with validations instead of exceptions (Errno::ENOENT, OpenURI:HTTPError, etc)
  end
  
end