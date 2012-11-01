# Based on http://blog.commonthread.com/2008/2/25/tip-rails-default-data-migrations
require "active_record/fixtures" 

class CreateCountries < ActiveRecord::Migration

  def self.up
    create_table :countries do |t|
      t.string :name, :limit => 40
      t.string :country_code, :limit => 2
    end
    
    # Import from YML
    Fixtures.create_fixtures(
      "db/fixtures", 
      "countries", 
      :countries => "CreateCountries::Country" 
    )
  end

  def self.down
    drop_table :countries
  end
  
end