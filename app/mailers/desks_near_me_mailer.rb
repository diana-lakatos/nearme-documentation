class DesksNearMeMailer < ActionMailer::Base
  extend Job::SyntaxEnhancer
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations
  default from: "support@desksnear.me"
  default reply_to: "support@desksnear.me"
  layout 'mailer'
end
