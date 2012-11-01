class Follower < ActiveRecord::Base
  
  ### Behavior
  ### Associations
  belongs_to :follower, :class_name => 'User'
  belongs_to :follows_user, :class_name => 'User'

  ### Validations
  validates_presence_of :follower_id, :follows_user_id
  validates_uniqueness_of :follows_user_id, :scope => :follower_id
  #validates_acceptance_of :not_following_yourself, :message => 'is a requirement.'

  ### Callbacks
  after_create :notify_follows_user

  ### Instance Methods
  
  def not_following_yourself
    self.follower_id != self.follows_user_id
  end
  
  def notify_follows_user
    begin
      # If has a Follows-User && Follows-User.has_email
      if (self.follows_user && self.follows_user.can_receive_email?)
        # Send email
        Emailer.deliver_follows_user_notification(self.follows_user, self.follower)
      end
    rescue
      # Error
      logger.warn "Could not send email to user #{self.follows_user.id}."
    end
  end
  
  ### Class Methods
  
  def Follower.is_following?(user, follows_user)
    return (Follower.find(:first, :conditions => ["follower_id = ? AND follows_user_id = ?", user.id, follows_user.id]))
  end

end