DesksnearMe::Application.configure do

  config.cache_classes = false

  config.whiny_nils = true

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.gmail.com',
    :port           => '587',
    :authentication => :plain,
    :enable_starttls_auto => true,
    :user_name      => "mani@maniempire.com",
    :password       => "thevanyesu",
    :domain         => 'maniempire.com'
  }

  config.active_support.deprecation = :log

  config.action_dispatch.best_standards_support = :builtin

  config.assets.digest = false

end
