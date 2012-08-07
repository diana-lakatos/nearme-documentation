class DesksNearMeMailer < ActionMailer::Base
  default from: "no-reply@desksnear.me"
  default_url_options[:host] = "desksnear.me"
end