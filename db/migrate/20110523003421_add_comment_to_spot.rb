class AddCommentToSpot < ActiveRecord::Migration
  def self.up
    add_column :spots, :comment, :string, :limit => 140
  end

  def self.down
    remove_column :spots, :comment
  end
end