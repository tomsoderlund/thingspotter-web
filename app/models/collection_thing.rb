class CollectionThing < ActiveRecord::Base
  
  ### Behavior
  
  ### Associations
  belongs_to :collection, :counter_cache => true
  belongs_to :thing
  
  ### Validations
  validates_presence_of :collection_id, :thing_id

  ### Callbacks
  before_destroy :touch_collection_date
  after_create   :touch_collection_date
  after_create   :notify_other_users
  
  ### Instance Methods

  def notify_other_users
    #begin
      # Notify ALL that have spotted/commented this Thing
      email_address_array = Array.new
      # Loop through Spots
      self.thing.related_users.each do |user|
        if (user != self.collection.user && user.can_receive_email? && email_address_array.index(user.email).nil?)
          # Send email
          Emailer.deliver_collection_added_notification(user, self.collection, self.thing)
          email_address_array << user.email
        end
      end
    # rescue
    #   # Error
    #   logger.warn "Could not send email for CollectionThing #{self.id}."
    # end
  end
  
  # Update updated_at date on Collection
  def touch_collection_date
    self.collection.updated_at = DateTime.now()
    self.collection.save
  end
  
  ### Class Methods
  
end