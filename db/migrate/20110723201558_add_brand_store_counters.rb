class AddBrandStoreCounters < ActiveRecord::Migration

  def self.up
    add_column :brands, :things_count, :integer, :default => 0
    add_column :stores, :spots_count, :integer, :default => 0
    
    # Update existing
    
    Brand.all.each do |brand|
      Brand.update_counters brand.id, :things_count => brand.things.count
    end
    
    Store.all.each do |store|
      Store.update_counters store.id, :spots_count => store.spots.count
    end
    
  end

  def self.down
    remove_column :brands, :things_count
    remove_column :stores, :spots_count
  end

end