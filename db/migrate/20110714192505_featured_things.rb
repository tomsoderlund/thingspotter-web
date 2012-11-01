class FeaturedThings < ActiveRecord::Migration

  def self.up
    add_column :things, :is_featured, :boolean, :default => false

    # Clean up
    remove_column :things, :product_page_url
    remove_column :things, :category_id
  end

  def self.down
    remove_column :things, :is_featured

    add_column :things, :product_page_url, :string, :limit => 128
    add_column :things, :category_id, :integer
  end

end