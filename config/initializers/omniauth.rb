Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, :setup => Authentication::TwitterProvider.setup_proc, image_size: 'original'
  provider :facebook, :setup => Authentication::FacebookProvider.setup_proc, image_size: {width: 500}
  provider :linkedin, :setup => Authentication::LinkedinProvider.setup_proc, scope: 'r_emailaddress', fields: ['id', 'first-name', 'last-name', 'headline', 'industry', 'picture-url', 'public-profile-url', 'email-address']
  provider :instagram, :setup => Authentication::InstagramProvider.setup_proc
end
