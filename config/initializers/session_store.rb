# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_note_feeder_session',
  :secret      => '2742c1d3f3c8179db9c761ecf7e5e01d8b7620e198ea7d292323ac0c594cba4366fe49bdee6d2209f735996f0b17c5df8694e57fe7cf8ebfc7c4d2dec350971d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
