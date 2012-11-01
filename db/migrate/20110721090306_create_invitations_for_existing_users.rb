class CreateInvitationsForExistingUsers < ActiveRecord::Migration
  
  def self.up
    
    User.find(:all, :conditions => "email IS NOT NULL").each do |user|
      invitation = Invitation.new(:recipient_email => user.email)
      invitation.save(false)
    	user.invitation_token = invitation.token
    	user.save(false)
    end
    
  end

  def self.down
    Invitation.delete_all
  end

end