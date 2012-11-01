# Based on http://blog.commonthread.com/2008/2/25/tip-rails-default-data-migrations

require "active_record/fixtures" 

class CreateLanguages < ActiveRecord::Migration
  
  def self.up
    create_table :languages do |t|
      t.string :name, :limit => 10
      t.string :language_code, :limit => 2
    end

    # Import from YML
    Fixtures.create_fixtures(
      "db/fixtures", 
      "languages", 
      :languages => "CreateLanguages::Language" 
    )
  end

  def self.down
    drop_table :languages
  end
  
end