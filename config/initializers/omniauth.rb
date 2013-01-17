require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, '7mByGM5byDFS8LLEotJokw',  'iC9zJrqTAoqxIMaccp12XDbC6FkBGrMEoX5Bm2A9k'
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
  unless Rails.env.production?
    provider :facebook, '563466820348243', '3a2cfb2ae0ce4e16bddcb30de6a92149'
  else
    provider :facebook, '301871243226028', 'ac8bb27ccebedccc7535d0df73e60640'
  end

  provider :linkedin, '2qyp4vpjl8uh', 'PQfyGFyutsoPwcOY', client_options: {request_token_path: '/uas/oauth/requestToken?scope=r_emailaddress'}, fields: ['id', 'first-name', 'last-name', 'headline', 'industry', 'picture-url', 'public-profile-url', 'email-address']
end
