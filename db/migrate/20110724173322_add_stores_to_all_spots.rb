class AddStoresToAllSpots < ActiveRecord::Migration
  
  def self.up
    Spot.find(:all, :conditions => "website_url IS NOT NULL").each do |spot|
      spot.guess_store
    	spot.save(false)
    end
  end

  def self.down
    Spot.find(:all, :conditions => "website_url IS NOT NULL").each do |spot|
      spot.store = nil
    	spot.save(false)
    end
  end

end