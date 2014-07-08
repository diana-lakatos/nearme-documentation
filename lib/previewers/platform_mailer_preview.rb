class PlatformMailerPreview < MailView

  def email_notification
    mailer = ::PlatformMailer.email_notification("test@example.com")
  end

end
