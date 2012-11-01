class CreateThings < ActiveRecord::Migration
  
  def self.up
    create_table :things do |t|
      t.integer :user_id
      t.string :name, :limit => 64
      t.text :description
      t.string :product_page_url, :limit => 128
      t.integer :brand_id
      t.integer :category_id
      t.string :barcode, :limit => 16

      # Photo
      t.string :photo_file_name, :limit => 128
      t.string :photo_content_type, :limit => 16
      t.integer :photo_file_size
      t.datetime :photo_updated_at
      
      # Timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :things
  end
  
end