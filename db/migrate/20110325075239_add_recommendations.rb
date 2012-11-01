class AddRecommendations < ActiveRecord::Migration

  def self.up
    add_column :spots, :recommended_to_user_id, :integer
    
    Spot.find(:all).each do |spot|
    	spot.product.user = spot.user
    	spot.product.save
    end
  end

  def self.down
    remove_column :spots, :recommended_to_user_id
  end
  
end