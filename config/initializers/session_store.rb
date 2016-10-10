# Be sure to restart your server when you modify this file.

# DesksnearMe::Application.config.session_store :cookie_store, :key => '_desksnear.me_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
if DesksnearMe::Application.config.cache_store[0] == :redis_store
  redis_store_hash = {
    servers: {
      host: DesksnearMe::Application.config.redis_settings['host'],
      port: DesksnearMe::Application.config.redis_settings['port'].to_i,
      namespace: 'sessions'
    },
    expire_after: 14.days
  }
  DesksnearMe::Application.config.session_store :redis_store, redis_store_hash
else
  DesksnearMe::Application.config.session_store = :cookie_store, { expire_after: 14.days }
end
