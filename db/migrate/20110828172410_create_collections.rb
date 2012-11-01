class CreateCollections < ActiveRecord::Migration
  
  def self.up
    create_table :collections do |t|
      t.string :name, :limit => 64
      t.text :description
      t.integer :user_id
      t.integer :collection_things_count, :default => 0
      t.boolean :is_featured, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :collections
  end
  
end