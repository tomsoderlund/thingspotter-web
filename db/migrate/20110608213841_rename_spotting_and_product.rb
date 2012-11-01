class RenameSpottingAndProduct < ActiveRecord::Migration
  # def self.up
  #   rename_table :spottings, :spots
  #   rename_table :products, :things
  #   
  #   rename_column :spots, :product_id, :thing_id
  #   rename_column :spots, :original_spotting_id, :original_spot_id
  # end
  # 
  # def self.down
  #   rename_column :spots, :thing_id, :product_id
  #   rename_column :spots, :original_spot_id, :original_spotting_id
  # 
  #   rename_table :spots, :spottings
  #   rename_table :things, :products
  # end
end
