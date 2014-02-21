class UserMailer < InstanceMailer
  helper SharingHelper

  layout 'mailer' 

  def notify_about_wrong_phone_number(user)
    @user = user

    mail(to: @user.email,
         subject: instance_prefix("#{@user.first_name}, we can't reach you!"))
  end

  def mail_type
    DNM::MAIL_TYPES::TRANSACTIONAL
  end

end
