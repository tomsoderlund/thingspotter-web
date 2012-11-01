class CreateCollectionThings < ActiveRecord::Migration
  def self.up
    create_table :collection_things do |t|
      t.integer :collection_id
      t.integer :thing_id
      t.integer :position, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :collection_things
  end
  
end