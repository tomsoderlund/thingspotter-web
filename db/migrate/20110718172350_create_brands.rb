class CreateBrands < ActiveRecord::Migration

  def self.up
    create_table :brands do |t|
      t.string :name, :limit => 64
      t.string :website, :limit => 64
      t.string :search_url, :limit => 128
      t.timestamps
    end
  end

  def self.down
    drop_table :brands
  end

end