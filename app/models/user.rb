require 'lib/thingspotter_lib'; include ThingspotterLib

class User < ActiveRecord::Base

  ### Behavior
  attr_accessible :name, :email, :gender_id, :born_at, :country_id, :language_id, :currency_id, :timezone_id, :post_to_facebook, :email_newsletter, :email_notifications, :invitation_token, :tag_list

  acts_as_taggable

  ### Associations
  has_many :spots, :dependent => :destroy
  has_many :collections, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :things
  has_many :friends, :dependent => :destroy
  has_many :friend_users, :through => :friends
  belongs_to :country
  belongs_to :language
  # THEY follow you
  has_many :followers, :foreign_key => 'follows_user_id', :class_name => 'Follower', :dependent => :destroy
  has_many :follower_users, :through => :followers, :source => :follower
  # YOU follow them
  has_many :followings, :foreign_key => 'follower_id', :class_name => 'Follower', :dependent => :destroy
  has_many :following_users, :through => :followings, :source => :follows_user
  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation, :dependent => :destroy
  
  ### Validations
  validates_uniqueness_of :fb_user_id
  validates_uniqueness_of :email, :allow_nil => true
  # INVITE BEHAVIOR: change here
  #validates_presence_of :invitation_id, :message => 'is required'
  #validates_uniqueness_of :invitation_id

  ### Callbacks
  before_create :set_user_defaults
  #after_create :set_user_followings
  #after_create :register_user_to_fb

  
  ### Instance Methods

  def to_param
    return "#{self.id}-#{self.name.gsub(' ', '-').gsub(/[^a-z0-9\-]+/i, '')}".downcase
  end

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
    
  def is_registered?
    return !(self.fb_access_token.nil? && self.fb_session_key.nil?)
  end
  
  def befriend(user)
    Friend.create(:user_id => self.id, :friend_user_id => user.id)
  end
  
  def find_friend_users(name = nil, include_non_users = false)
    User.find_by_sql("SELECT users.id, users.name, users.fb_user_id, users.fb_access_token, users.fb_session_key, users.spots_count FROM users LEFT OUTER JOIN friends ON friends.friend_user_id = users.id WHERE (friends.user_id = " + self.id.to_s + (name.blank? ? "" : " AND users.name LIKE '" + name + "%'") + (include_non_users ? "" : " AND (users.fb_access_token IS NOT NULL OR users.fb_session_key IS NOT NULL)") + ") ORDER BY users.name;")
  end

  def find_friend_users_not_on_thingspotter(order = 'users.name')
    User.find_by_sql("SELECT users.id, users.name, users.fb_user_id, users.fb_access_token, users.fb_session_key, users.spots_count FROM users LEFT OUTER JOIN friends ON friends.friend_user_id = users.id WHERE (friends.user_id = " + self.id.to_s + (" AND (users.fb_access_token IS NULL AND users.fb_session_key IS NULL)") + ") ORDER BY " + order + ";")
  end

  def find_following_users(name = nil, include_non_users = false)
    User.find_by_sql("SELECT users.id, users.name, users.fb_user_id, users.fb_access_token, users.fb_session_key, users.spots_count FROM users LEFT OUTER JOIN followers ON followers.follows_user_id = users.id WHERE (followers.follower_id = " + self.id.to_s + (name.blank? ? "" : " AND users.name LIKE '" + name + "%'") + (include_non_users ? "" : " AND (users.fb_access_token IS NOT NULL OR users.fb_session_key IS NOT NULL)") + ") ORDER BY users.name;")
  end

  def follows?(user)
    return Follower.is_following?(self, user)
  end
  
  def follow(user)
    Follower.create(:follower_id => self.id, :follows_user_id => user.id)
  end
  
  def subscribed_spots(page = 1, order = nil)
    following_user_ids = [self.id]
    self.followings.each do |follower|
      following_user_ids << follower.follows_user_id
    end
    #conditions = "spots.recommended_to_user_id = " + self.id.to_s + " OR spots.user_id IN (" + following_user_ids.join(',') + ")"
    conditions = ["spots.recommended_to_user_id = ? OR spots.user_id IN (" + following_user_ids.join(',') + ") OR things.is_featured = ?", self.id, true]
    
    # TODO: :select => 'DISTINCT thing_id, *', 
    return Spot.search(nil, conditions, order, page)
  end
  
  def all_spots(page = 1)
    return Spot.search(nil, ["user_id = ?", self.id], nil, page)
  end
  
  def wanted_spots(page = 1)
    return Spot.search(nil, ["user_id = ? AND is_wanted = ?", self.id, true], nil, page)
  end
  
  def owned_spots(page = 1)
    return Spot.search(nil, ["user_id = ? AND is_owned = ?", self.id, true], nil, page)
  end
  
  def wishlist_spots(page = 1)
    return Spot.search(nil, ["user_id = ? AND is_wanted = ? AND is_owned = ?", self.id, true, false], nil, page)
  end
  
  def recommended_spots(page = 1)
    return Spot.search(nil, ["user_id = ? AND recommended_to_user_id IS NOT NULL", self.id], nil, page)
  end

  def related_users
    tags_to_find = self.tag_list.join(', ')
    user_array = User.find_tagged_with(tags_to_find, :match_all => true).sort_by(&:spots_count).reverse #.sample(10)
    # Too small? Try Users with ANY similar tags
    if user_array.size < 3
      user_array = user_array + User.find_tagged_with(tags_to_find, :match_all => false).sort_by(&:spots_count).reverse
    end
    # Still too small? Try Users with many spots
    if user_array.size < 3
      user_array = user_array + User.find(:all, :order => "spots_count desc", :limit => (5-user_array.size))
    end
    # Remove thyself
    user_array.delete(self)
    return user_array
  end
  
  # Find the user in the database, first by the facebook user id and if that fails through the email hash
  def self.find_by_fb_user(fb_user)
    begin
      User.find_by_fb_user_id(fb_user.uid) || User.find_by_email_hash(fb_user.email_hashes)
    rescue
      return nil
    end
  end
  
  # We are going to connect this user object with a facebook id. But only ever one account.
  def link_fb_connect(fb_user_id, invitation_token = nil)
    unless fb_user_id.nil?
      # check for existing account
      existing_fb_user = User.find_by_fb_user_id(fb_user_id)
      # unlink the existing account
      unless existing_fb_user.nil?
        existing_fb_user.fb_user_id = nil
        existing_fb_user.save(false)
      end
      # link the new one
      self.fb_user_id = fb_user_id
      self.invitation_token = invitation_token if invitation_token
      self.save(false)
    end
  end
  
  # The Facebook registers user method is going to send the users email hash and our account id to Facebook
  # We need this so Facebook can find friends on our local application even if they have not connect through connect
  # We then use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    users = {:email => email, :account_id => id}
    Facebooker::User.register([users])
    self.email_hash = Facebooker::User.hash_email(email)
    save(false)
  end
  
  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
  end
  
  def import_facebook_friends(friends)
  	#logger.debug "import_facebook_friends: #{friends.size}"
    begin
      friends.each do |friend|
      	#logger.debug friend['name']
      	# Create User
      	friend_user = User.find_or_create_by_fb_user_id(friend['id']) { |u| u.name = friend['name'] }
      	# Create Friend Relationship
      	self.befriend(friend_user)
      end
      
      return true
    rescue
      return false
    end
    
  end
  
  def can_receive_email?
    return (self.email && self.email_notifications)
  end
  
  def currency
    return reverse_lookup_in_array(self.currency_id, User.currency_list)
  end

  def set_user_followings
    # Make default followings
    self.follow(User.find_by_fb_user_id(635077092)) # Tom
    self.follow(User.find_by_fb_user_id(737055288)) # Paulina
    return true
  end


  ### Class Methods
  
  # Take the data returned from Facebook and create a new user from it.
  # We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
  # If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
  def User.create_from_fb_connect(fb_user, invitation_token = nil)
    logger.debug "User.create_from_fb_connect: #{fb_user['id']}, #{invitation_token}"

    # Debug
    # logger.debug 'Facebooker: fb_user ' + fb_user.uid.to_s
    # logger.debug '  current_location: ' + fb_user.current_location.country.to_s if fb_user.current_location
    # logger.debug '  hometown_location: ' + fb_user.hometown_location.to_s
    # logger.debug '  sex: ' + fb_user.sex.to_s               # male, WORKS
    # logger.debug '  locale: ' + fb_user.locale.to_s            # en_US, WORKS
    # logger.debug '  birthday: ' + fb_user.birthday.to_s
    # logger.debug '  birthday_date: ' + fb_user.birthday_date.to_s
    # logger.debug '  email: ' + fb_user.email.to_s

    #user = User.find_or_create_by_fb_user_id(fb_user.uid.to_i)
    
    user = User.find_by_fb_user_id(fb_user['id'].to_i)
    if user
      # User Exists
    else
      # New FB user
      user = User.new(:name => fb_user['name'])
      user.fb_user_id = fb_user['id'].to_i
      user.gender_id = lookup_in_array(fb_user['gender'], User.gender_list) if fb_user['gender'] # "female"
      user.email = fb_user['email'] if fb_user['email'] # Need 'email' in permsToRequestOnConnect
      user.language = Language.find_by_language_code(fb_user['locale'].split('_')[0]) if fb_user['locale'] # locale = "en_US" -> "en"
      #user.country = Country.find_by_country_code(fb_user.locale.split('_')[1]) if fb_user.locale # -> "US"
      user.country = Country.find_by_country_code("US")
      user.country = Country.find_by_name(fb_user['location']['name'].split(', ')[1]) if fb_user['location'] # "Sweden"
      user.timezone_id = 100 # CET, +1:00
      user.currency_id = 0 # USD
      # Save without validations
      user.save(false)
    end
    
    # For both existing and new users
    unless invitation_token.blank?
      user.invitation_token = invitation_token
      # Take email from Invitation if not set from Facebook
      user.email = user.invitation.recipient_email if user.email.nil?
      # Save without validations
      user.save(false)
    end

    #logger.debug user.inspect
    #logger.debug user.errors.full_messages unless user.errors.empty?
    
    return user
    
  end
  
  def User.competition_list(date_start = Date.new(2011, Date.today.month, 1), date_end = Date.new(2011, (Date.today.month+1), 1))
    
    # 1: New spots = 1p.
    list1 = User.find_by_sql("SELECT users.id, users.fb_user_id, users.name, (count(spots.id) * 1) AS points, users.is_admin, users.fb_access_token, users.fb_session_key FROM spots LEFT OUTER JOIN users ON users.id = spots.user_id WHERE (spots.created_at > '" + date_start.to_s + "' AND spots.created_at < '" + date_end.to_s + "' AND spots.original_spot_id IS NULL AND spots.recommended_to_user_id IS NULL) GROUP BY spots.user_id ORDER BY points desc;")
    # 2: Re-spots = 5p to the original spotter.
    list2 = User.find_by_sql("SELECT users.id, users.fb_user_id, users.name, (count(spots.id) * 5) AS points, users.is_admin, users.fb_access_token, users.fb_session_key FROM spots LEFT OUTER JOIN spots AS original_spots ON original_spots.id = spots.original_spot_id LEFT OUTER JOIN users ON users.id = original_spots.user_id WHERE (spots.created_at > '" + date_start.to_s + "' AND spots.created_at < '" + date_end.to_s + "' AND spots.original_spot_id IS NOT NULL) GROUP BY original_spots.user_id ORDER BY points desc;")
    # 3: Recommendations = 5p to the one doing the recommendation.
    list3 = User.find_by_sql("SELECT users.id, users.fb_user_id, users.name, (count(spots.id) * 5) AS points, users.is_admin, users.fb_access_token, users.fb_session_key FROM spots LEFT OUTER JOIN users ON users.id = spots.user_id WHERE (spots.created_at > '" + date_start.to_s + "' AND spots.created_at < '" + date_end.to_s + "' AND spots.recommended_to_user_id IS NOT NULL) GROUP BY spots.user_id ORDER BY points desc;")
    # 4: Comments = 5p to commenter (excluding comments on your own spots).
    list4 = User.find_by_sql("SELECT users.id, users.fb_user_id, users.name, (count(comments.id) * 5) AS points, users.is_admin, users.fb_access_token, users.fb_session_key FROM comments LEFT OUTER JOIN users ON users.id = comments.user_id LEFT OUTER JOIN things ON things.id = comments.thing_id WHERE (comments.created_at > '" + date_start.to_s + "' AND comments.created_at < '" + date_end.to_s + "' AND comments.user_id != things.user_id) GROUP BY comments.user_id ORDER BY points desc;")

    # Accumulate lists
    result_list = list1.clone # copy list1
    
    [list2, list3, list4].each do |list|
      list.each do |new_user|
        existing_user = list1.find {|old_user| old_user[:id] == new_user[:id]}
        if existing_user.nil?
          result_list << new_user
        else
          existing_user.points += new_user.points
        end
      end
    end
    
    # Clean NIL's
    result_list.each do |user|
      result_list.delete(user) if user.id.nil?
      result_list.delete(user) if user.is_admin
    end
    
    # Sort
    result_list = result_list.sort_by(&:points).reverse
    
    return result_list
  end

  # Class method to get list for dropdowns etc
  def User.short_list
    return self.find(:all, :conditions => 'is_admin = 1', :order => :login).map do |t| 
      [t.login, t.id] 
    end
  end

  # gender_id
  def User.gender_list
    [
      ['female', 1], 
      ['male', 2]
    ]
  end

  # timezone_id
  def User.timezone_list
    [
      ['UTC-12:00 (US Minor Outlying Islands)', -1200],
      ['UTC-11:00 (Samoa)', -1100],
      ['UTC-10:00 (Hawaii)', -1000],
      ['UTC-9:00 AKT (Alaska Time Zone)', -900],
      ['UTC-8:00 PT (Pacific Time)', -800],
      ['UTC-7:00 MT (Mountain Time)', -700],
      ['UTC-6:00 CT (Central Time)', -600],
      ['UTC-5:00 ET (Eastern Time)', -500],
      ['UTC-4:30 (Venezuela)', -450],
      ['UTC-4:00 AT (Atlantic Time: Quebec)', -400],
      ['UTC-3:30 NST (Newfoundland Standard Time)', -350],
      ['UTC-3:00 (Argentina, Brazil)', -300],
      ['UTC-2:00 (Brazil - Ocean Islands)', -200],
      ['UTC-1:00 (Greenland)', -100],
      ['UTC+0:00 (United Kingdom, Portugal)', 0],
      ['UTC+1:00 CET (Central European Time)', 100],
      ['UTC+2:00 (Greece, Finland)', 200],
      ['UTC+3:00 (Kenya, Saudi Arabia)', 300],
      ['UTC+3:30 (Iran)', 350],
      ['UTC+4:00 (Moscow)', 400],
      ['UTC+4:30 (Afghanistan)', 450],
      ['UTC+5:00 (Pakistan)', 500],
      ['UTC+5:30 IST (India)', 550],
      ['UTC+5:45 (Nepal)', 575],
      ['UTC+6:00 (Bangladesh)', 600],
      ['UTC+6:30 (Myanmar)', 650],
      ['UTC+7:00 (Indonesia, Thailand)', 700],
      ['UTC+8:00 (Australia, Philippines)', 800],
      ['UTC+8:45 (Western Australia)', 875],
      ['UTC+9:00 (Japan, South Korea)', 900],
      ['UTC+9:30 ACST (Australian Central Time)', 950],
      ['UTC+10:00 AEST (Australian Eastern Time)', 1000],
      ['UTC+10:30 (Australia: New South Wales)', 1050],
      ['UTC+11:00 (Micronesia)', 1100],
      ['UTC+11:30 (Norfolk Island)', 1150],
      ['UTC+12:00 (New Zealand)', 1200],
      ['UTC+12:45 (New Zealand)', 1275],
      ['UTC+13:00 (Tonga)', 1300],
      ['UTC+14:00 (Kiribati Line Islands)', 1400]
    ]
  end

  # currency_id
  def User.currency_list
    [
      ['USD', 0],
      ['EUR', 1],
      ['GBP', 2],
      ['SEK', 3]
    ]
  end


private

  def set_user_defaults
    self.invitation_limit = 10
    self.post_to_facebook = false
    self.post_to_twitter = false
    return true # Necessary to save User
  end
  
end