class DesksNearMeMailer < ActionMailer::Base
  extend Job::SyntaxEnhancer
  include ActionView::Helpers::TextHelper
  self.job_class = MailerJob

  helper :listings, :reservations
  default from: "support@desksnear.me"
  default reply_to: "support@desksnear.me"
  layout 'mailer'

  private
  def subject(text)
    text.prepend "[#{@theme.name}] " if @theme
    text
  end

end
