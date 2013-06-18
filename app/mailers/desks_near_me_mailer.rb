class DesksNearMeMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations
  default from: "support@desksnear.me"
  default reply_to: "support@desksnear.me"
  default_url_options[:host] = "desksnear.me"
  layout 'mailer'
end
