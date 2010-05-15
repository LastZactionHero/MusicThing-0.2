# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_musicthing0.2_session',
  :secret      => '03f561851676829c37e160ff698eff00413edc7b6f3a71224cb2b7f03f0c7313930c97f3180c9828a9f20a0cbe228e40d1d85faf158521ed0025423a54757923'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
