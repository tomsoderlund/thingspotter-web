class AddFacebookOauthAccessToken < ActiveRecord::Migration

  def self.up
    add_column :users, :fb_access_token, :string, :limit => 100
  end

  def self.down
    remove_column :users, :fb_access_token
  end

end