class DesksNearMeMailer < ActionMailer::Base
	helper :listings
  default from: "no-reply@desksnear.me"
  default_url_options[:host] = "desksnear.me"
  layout 'mailer'
end