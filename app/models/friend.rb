class Friend < ActiveRecord::Base

  ### Behavior
  ### Associations
  belongs_to :user
  belongs_to :friend_user, :class_name => 'User', :foreign_key => 'friend_user_id'
  
  ### Validations
  validates_uniqueness_of :friend_user_id, :scope => :user_id

  ### Callbacks
  ### Instance Methods
  ### Class Methods
  
end
