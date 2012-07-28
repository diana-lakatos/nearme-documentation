require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, '7mByGM5byDFS8LLEotJokw',  'iC9zJrqTAoqxIMaccp12XDbC6FkBGrMEoX5Bm2A9k'
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
end
