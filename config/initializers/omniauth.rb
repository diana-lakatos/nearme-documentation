require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, '7mByGM5byDFS8LLEotJokw', 'iC9zJrqTAoqxIMaccp12XDbC6FkBGrMEoX5Bm2A9k'
  provider :facebook, '110643308998534', '4456707d6ff950c0f3a1aeaeefeac933', :scope => 'publish_stream'
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
end
