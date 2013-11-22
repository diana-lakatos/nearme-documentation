class UserMailer < InstanceMailer
  helper SharingHelper

  layout 'mailer' 

  def notify_about_wrong_phone_number(platform_context, user)
    @user = user
    @platform_context = platform_context

    mail(to: @user.email,
         subject: instance_prefix("#{@user.first_name}, we can't reach you!", platform_context.decorate),
         platform_context: @platform_context)
  end

  def mail_type
    DNM::MAIL_TYPES::TRANSACTIONAL
  end

end
