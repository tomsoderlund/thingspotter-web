class CreateSpots < ActiveRecord::Migration
  
  def self.up
    create_table :spots do |t|
      t.integer :user_id
      t.integer :thing_id
      t.integer :vendor_id
      t.string  :website_url, :limit => 128
      t.float   :price
      t.integer :currency_id
      t.boolean :is_wanted, :default => false
      t.boolean :is_owned, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :spots
  end

end