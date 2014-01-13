class PlatformMailer < ActionMailer::Base

  def email_notification(email)
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    unsubscribe_key = verifier.generate(email.email)
    @unsubscribe_url = "http://near-me.com/unsubscribe/#{unsubscribe_key}"

    mail from: 'michelle@near-me.com',
         to: email.email,
         subject: "Hello from NearMe!"
  end

  def email_a_friend(from_name, to_email)
    mail from: from_name,
         to: to_email,
         subject: "#{from_name} has shared a Near Me page with you",
         layout: false
  end
end
