# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

# Raise email errors?
config.action_mailer.raise_delivery_errors = true

# Email Settings - from http://wiki.rubyonrails.com/rails/pages/HowToSendEmailsWithActionMailer
ActionMailer::Base.smtp_settings = {
  :address  => "localhost",
  :port  => 25,
  :domain  => "thingspotter.com"
}

$EMAIL_SENDER_NAME = 'Thingspotter Staging'
$EMAIL_SENDER_ADDRESS = 'info@thingspotter.com'
$SERVER_URL = 'http://www.thingspotter.com:8129'