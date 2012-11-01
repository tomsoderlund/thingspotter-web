class Invitation < ActiveRecord::Base
  
  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  validates_presence_of :recipient_email
  validates_uniqueness_of :recipient_email, :allow_nil => true
  validates_exclusion_of :recipient_email, :in => ['Email address'], :message => "is not a valid email address"
  validate :recipient_is_not_registered
  validate :sender_has_invitations, :if => :sender

  before_create :blank_fields, :generate_token
  before_create :decrement_sender_count, :if => :sender


private

  def recipient_is_not_registered
    return true if self.recipient_email.blank?
    errors.add :recipient_email, 'is already registered' if User.find_by_email(recipient_email)
  end

  def sender_has_invitations
    unless sender.invitation_limit > 0
      errors.add_to_base 'You have reached your limit of invitations to send.'
    end
  end

  def blank_fields
    self.recipient_email = nil if self.recipient_email.blank?
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def decrement_sender_count
    #sender.decrement! :invitation_limit unless sender.is_admin
  end

end