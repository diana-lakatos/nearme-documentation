class DesksNearMeMailer < ActionMailer::Base
  include Job::MailerJobSyntaxEnhancer
  include ActionView::Helpers::TextHelper
  helper :listings, :reservations
  default from: "support@desksnear.me"
  default reply_to: "support@desksnear.me"
  layout 'mailer'

  private
  def subject(text)
    text.prepend "[#{@instance.name}] " if @instance
    text
  end
end
