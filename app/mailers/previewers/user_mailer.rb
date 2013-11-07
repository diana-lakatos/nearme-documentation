if defined? MailView
  class Previewers::UserMailer < MailView

    def notify_about_wrong_phone_number
      ::UserMailer.notify_about_wrong_phone_number(PlatformContext.new, User.where('mobile_number is not null').first)
    end

  end
end
