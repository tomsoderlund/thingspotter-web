class MoreSpotWebsiteOptions < ActiveRecord::Migration
  
  def self.up
    change_column :spots, :website_url, :string, :limit => 256
    add_column :spots, :is_website_store, :boolean, :default => false
    add_column :spots, :is_website_productpage, :boolean, :default => false
  end

  def self.down
    change_column :spots, :website_url, :string, :limit => 128
    remove_column :spots, :is_website_store
    remove_column :spots, :is_website_productpage
  end
  
end