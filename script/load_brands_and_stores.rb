# Set environment to command line argument #1
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'  

require File.join(File.dirname(__FILE__), '../config/environment')
require "active_record/fixtures" 

puts "Import data from db/fixtures"

puts "Brands..."
Fixtures.create_fixtures("db/fixtures", "brands", :brands => 'Brand')

puts "Stores..."
Fixtures.create_fixtures("db/fixtures", "stores", :stores => 'Store')

puts "Done!"