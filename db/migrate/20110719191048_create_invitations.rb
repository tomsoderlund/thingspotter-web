class CreateInvitations < ActiveRecord::Migration
  
  def self.up
    create_table :invitations do |t|
      t.integer :sender_id
      t.string :recipient_email
      t.string :token
      t.datetime :sent_at
      t.timestamps
    end

    add_column :users, :invitation_id, :integer
    add_column :users, :invitation_limit, :integer, :default => 0

  end

  def self.down
    drop_table :invitations

    remove_column :users, :invitation_id
    remove_column :users, :invitation_limit
  end

end