class Comment < ActiveRecord::Base

  ### Behavior
  ### Associations
  belongs_to :user
  belongs_to :thing
  belongs_to :spot

  ### Validations
  validates_presence_of :comment, :thing, :user
  validates_length_of :comment, :within => 2..140

  ### Callbacks
  after_create :notify_other_users
  
  ### Instance Methods
  
  def notify_other_users
    begin
      # Notify ALL that have spotted/commented this Thing
      email_address_array = Array.new
      # Loop through Spots
      self.thing.related_users.each do |user|
        # If Spot.User != Self.User && Spot.User.can_receive_email && Not already sent
        #logger.debug "notify_other_users: Send email to #{spot.user.name}? (#{spot.user != self.user} and #{spot.user.can_receive_email?} and #{email_address_array.index(spot.user.email).nil?})"
        if (user != self.user && user.can_receive_email? && email_address_array.index(user.email).nil?)
          # Send email
          Emailer.deliver_comment_notification(user, self)
          email_address_array << user.email
        end
      end
    rescue
      # Error
      logger.warn "Could not send email for comment #{self.id}."
    end
  end
  
  ### Class Methods
      
end
