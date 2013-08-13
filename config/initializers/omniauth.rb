Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Social::Twitter::KEY,  Social::Twitter::SECRET
  provider :facebook, Social::Facebook::KEY,  Social::Facebook::SECRET
  provider :linkedin, Social::Linkedin::KEY, Social::Linkedin::SECRET, client_options: {request_token_path: '/uas/oauth/requestToken?scope=r_emailaddress'}, fields: ['id', 'first-name', 'last-name', 'headline', 'industry', 'picture-url', 'public-profile-url', 'email-address']
end
