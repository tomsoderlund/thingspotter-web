class AddExternalPhotoToProducts < ActiveRecord::Migration
  
  def self.up
    add_column :things, :photo_remote_url, :string
  end

  def self.down
    remove_column :things, :photo_remote_url
  end

end