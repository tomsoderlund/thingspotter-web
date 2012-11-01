# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_DefaultAppFacebook_session',
  :secret      => '310897bcba76a33b2892d0a1ce76b296dfa339852dfd299086e60074d0c4b5026c31ec5875c287df7d2bd74084b8b9fa1a388f24aea18d9564627c4c4f8d748c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
