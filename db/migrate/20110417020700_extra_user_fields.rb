class ExtraUserFields < ActiveRecord::Migration
  
  def self.up
    add_column :users, :email, :string, :limit => 100
    add_column :users, :born_at, :date
    add_column :users, :gender_id, :integer
    add_column :users, :country_id, :integer
    add_column :users, :language_id, :integer
    add_column :users, :timezone_id, :integer
    add_column :users, :currency_id, :integer
    add_column :users, :is_admin, :boolean, :default => false
    add_column :users, :points, :integer, :default => 0
    add_column :users, :status_level_id, :integer, :default => 1
    add_column :users, :post_to_facebook, :boolean, :default => true
    add_column :users, :post_to_twitter, :boolean, :default => true
    add_column :users, :email_newsletter, :boolean, :default => true
    add_column :users, :email_notifications, :boolean, :default => true
    
    # Try to set Tom & Paulina as admins
    begin
      User.find_by_fb_user_id(635077092).update_attribute(:is_admin, true)
      User.find_by_fb_user_id(737055288).update_attribute(:is_admin, true)
    rescue
    end
    
  end

  def self.down
    remove_column :users, :email
    remove_column :users, :born_at
    remove_column :users, :country_id
    remove_column :users, :is_admin

    # remove_column :users, :gender_id
    # remove_column :users, :language_id
    # remove_column :users, :timezone_id
    # remove_column :users, :currency_id
    # remove_column :users, :points
    # remove_column :users, :status_level_id
    # remove_column :users, :post_to_facebook
    # remove_column :users, :post_to_twitter
    # remove_column :users, :email_newsletter
    # remove_column :users, :email_notifications
  end

end