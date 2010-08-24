# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_issustainable_session',
  :secret      => '729ed65f0b3acab5f2491e260b0108ef1d349aa5496f6fc19b1499b36a23365818790250a1fc590982443a7ec0669b2fa79490d29ded437fb918ec488c35c3e8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
