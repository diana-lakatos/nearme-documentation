class PlatformMailer < ActionMailer::Base
  extend Job::SyntaxEnhancer

  NOTIFICATIONS_EMAIL = 'sales@near-me.com'

  def email_notification(email)
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    unsubscribe_key = verifier.generate(email.email)
    @unsubscribe_url = platform_email_unsubscribe_url(unsubscribe_key)

    mail from: 'michelle@near-me.com',
         to: email.email,
         subject: "Hello from NearMe!"
  end

  def contact_request(platform_contact)
    @platform_contact = platform_contact
    mail from: 'notifications@near-me.com',
         to: NOTIFICATIONS_EMAIL,
         subject: "New NearMe contact form sumbission.",
         layout: false
  end

  def demo_request(platform_demo_request)
    @platform_demo_request = platform_demo_request
    mail from: 'notifications@near-me.com',
         to: NOTIFICATIONS_EMAIL,
         subject: "New NearMe demo request form submission.",
         layout: false
  end
end
