class CreateUsers < ActiveRecord::Migration
  
  def self.up
    create_table :users do |t|
      t.string :name, :limit => 100
      t.integer :fb_user_id # note: should be biginteger
      t.string :fb_session_key, :limit => 150 # for offline posting etc
      #t.string :email_hash   # only needed for dual-mode login with local email storage
      t.timestamps
    end
    
    # If MySQL
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql"
      execute("alter table users modify fb_user_id bigint")
    end
  end

  def self.down
    drop_table :users
  end
  
end