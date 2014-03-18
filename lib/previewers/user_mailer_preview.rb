class UserMailerPreview < MailView

  def notify_about_wrong_phone_number
    ::UserMailer.notify_about_wrong_phone_number(User.where('mobile_number is not null').first)
  end

end
