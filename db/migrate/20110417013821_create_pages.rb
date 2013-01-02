class CreatePages < ActiveRecord::Migration
  
  def self.up
    create_table :pages do |t|
      t.string :title
      t.text :body
      t.string :permalink
      t.integer :user_id
      t.timestamps
    end
    
    Page.create(:title => 'About', :permalink => 'about', :body => '...')
    Page.create(:title => 'Thingspotter Beta', :permalink => 'beta', :body => '...')
    Page.create(:title => 'Welcome!', :permalink => 'welcome_new_user', :body => '...')
  end

  def self.down
    drop_table :pages
  end
  
end