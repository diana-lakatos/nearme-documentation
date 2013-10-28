Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Social::Twitter::KEY,  Social::Twitter::SECRET
  provider :facebook, Social::Facebook::KEY,  Social::Facebook::SECRET, image_size: {width: 500}
  provider :linkedin, Social::Linkedin::KEY, Social::Linkedin::SECRET, scope: 'r_emailaddress r_network', fields: ['id', 'first-name', 'last-name', 'headline', 'industry', 'picture-url', 'public-profile-url', 'email-address', 'connections']
end
