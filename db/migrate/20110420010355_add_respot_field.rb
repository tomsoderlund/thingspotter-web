class AddRespotField < ActiveRecord::Migration
  
  def self.up
    add_column :spots, :original_spot_id, :integer
  end

  def self.down
    remove_column :spots, :original_spot_id
  end

end