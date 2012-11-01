class AddSpotCounters < ActiveRecord::Migration

  def self.up
    add_column :things, :spots_count, :integer, :default => 0
    add_column :users, :spots_count, :integer, :default => 0
    
    # Update existing
    
    Thing.all.each do |thing|
      thing.update_attribute(:spots_count, thing.spots.count)
    end
    
    User.all.each do |user|
      user.update_attribute(:spots_count, user.spots.count)
    end
    
  end

  def self.down
    remove_column :things, :spots_count
    remove_column :users, :spots_count
  end

end