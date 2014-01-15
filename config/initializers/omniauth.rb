Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Authentication::TwitterProvider::KEY,  Authentication::TwitterProvider::SECRET, image_size: 'original'
  provider :facebook, Authentication::FacebookProvider::KEY, Authentication::FacebookProvider::SECRET, image_size: {width: 500}
  provider :linkedin, Authentication::LinkedinProvider::KEY, Authentication::LinkedinProvider::SECRET, scope: 'r_emailaddress r_network', fields: ['id', 'first-name', 'last-name', 'headline', 'industry', 'picture-url', 'public-profile-url', 'email-address', 'connections']
  provider :instagram, Authentication::InstagramProvider::KEY, Authentication::InstagramProvider::SECRET
end
