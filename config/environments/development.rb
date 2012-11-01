# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Raise email errors?
config.action_mailer.raise_delivery_errors = true

# ActionMailer Gmail settings:
# http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail
# http://douglasfshearer.com/blog/gmail-smtp-with-ruby-on-rails-and-actionmailer
ActionMailer::Base.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "thingspotter.com",
    :authentication => 'plain',
    :user_name => "tom.soderlund@differentgame.org",
    :password => "Fr4gg3rG"
}

$EMAIL_SENDER_NAME = 'Thingspotter Dev'
$EMAIL_SENDER_ADDRESS = 'thingspotter@tomorroworld.com'
$SERVER_URL = 'http://localhost:3000'