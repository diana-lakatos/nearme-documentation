=begin
Omnisocial.setup do |config|
  
  # ==> Twitter
  # config.twitter 'APP_KEY', 'APP_SECRET'
  config.twitter '7mByGM5byDFS8LLEotJokw', 'iC9zJrqTAoqxIMaccp12XDbC6FkBGrMEoX5Bm2A9k'
  # ==> Facebook
  # config.facebook 'APP_KEY', 'APP_SECRET', :scope => 'publish_stream'
  config.facebook '110643308998534', '4456707d6ff950c0f3a1aeaeefeac933', :scope => 'publish_stream'
  if Rails.env.production?
    
    # Configs for production mode go here
    
  elsif Rails.env.development?
    
    # Configs for development mode go here
    
  end
  
end
=end
