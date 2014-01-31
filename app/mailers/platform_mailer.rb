class PlatformMailer < ActionMailer::Base
  extend Job::SyntaxEnhancer

  def email_notification(email)
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    unsubscribe_key = verifier.generate(email.email)
    @unsubscribe_url = platform_email_unsubscribe_url(unsubscribe_key)

    mail from: 'michelle@near-me.com',
         to: email.email,
         subject: "Hello from NearMe!"
  end

  def email_a_friend(from_name, to_email)
    mail from: 'Near Me <team@desksnear.me>',
         to: to_email,
         subject: "#{from_name} has shared a Near Me page with you",
         layout: false
  end
end
