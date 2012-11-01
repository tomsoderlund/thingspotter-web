class CreateComments < ActiveRecord::Migration
  
  def self.up
    
    create_table :comments do |t|
      t.integer :user_id
      t.integer :thing_id
      t.integer :spot_id
      t.string :comment, :limit => 140
      t.timestamps
    end

    # Move Comments from Spots
    Spot.all.each do |spot|
      if !spot.comment.blank?
        Comment.create(:comment => spot.comment, :user_id => spot.user.id, :spot_id => spot.id, :thing_id => spot.thing.id)
      end
    end
    
    # Delete old Comment column from Spots
    remove_column :spots, :comment

  end

  def self.down
    add_column :spots, :comment, :string, :limit => 140

    drop_table :comments
  end
  
end