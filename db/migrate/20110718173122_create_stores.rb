class CreateStores < ActiveRecord::Migration

  def self.up
    create_table :stores do |t|
      t.string :name, :limit => 64
      t.string :url_key, :limit => 128
      t.string :url_data, :limit => 128
      t.string :body_data, :limit => 256
      t.timestamps
    end

    rename_column :spots, :vendor_id, :store_id

  end

  def self.down
    drop_table :stores

    rename_column :spots, :store_id, :vendor_id

  end

end