# Based on http://blog.commonthread.com/2008/2/25/tip-rails-default-data-migrations
require "active_record/fixtures" 

class ActsAsTaggableMigration < ActiveRecord::Migration

  def self.up
    create_table :tags do |t|
      t.column :name, :string, :limit => 20
      t.column :show_by_default, :boolean, :default => false
    end
    
    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      # You should make sure that the column created is long enough to store the required class names.
      t.column :taggable_type, :string, :limit => 10
      t.column :created_at, :datetime
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]

    # Import from YML
    Fixtures.create_fixtures(
      "db/fixtures", 
      "tags", 
      :tags => "ActsAsTaggableMigration::Tag" 
    )
  end
  
  def self.down
    drop_table :taggings
    drop_table :tags
  end
  
end