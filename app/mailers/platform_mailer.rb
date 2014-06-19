class PlatformMailer < ActionMailer::Base
  extend Job::SyntaxEnhancer

  NOTIFICATIONS_EMAIL = 'sales@near-me.com'

  def email_notification(email)
    mail from: 'michelle@near-me.com',
         to: email,
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
