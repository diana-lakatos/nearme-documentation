class PostActionMailer < InstanceMailer
  helper SharingHelper

  layout 'mailer'

  def sign_up_verify(user)
    @user = user

    unless @user.verified_at
      mail to: @user.email,
           subject: "#{@user.first_name}, please verify your #{instance_name} email"
    end
  end

  def sign_up_welcome(user)
    @user = user
    @location = @user.locations.first

    mail(to: @user.email,
         subject: "#{@user.first_name }, welcome to #{instance_name}!")
  end

  def created_by_instance_admin(new_user, creator)
    @new_user = new_user
    @creator = creator

    mail(to: @new_user.email,
         subject: "#{@new_user.first_name }, you were invited to #{instance_name} by #{@creator.name}!")
  end

  def list_draft(user)
    @user = user

    mail to: @user.email,
           subject: "You're almost ready for your first guests!"
  end

  def list(user)
    @user = user
    @listing = @user.listings.first

    mail to: @user.email,
           subject: "#{@user.first_name}, your new listing looks amazing!"
  end

  def unsubscription(user, mailer_name)
    @user = user
    @mailer_name = mailer_name.split('/').last.humanize

    mail to: @user.email,
           subject: "Successfully unsubscribed"
  end

  def instance_created(instance, user, user_password)
    @user = user
    @user_password = user_password
    @instance = instance

    mail to: @user.email,
           subject: "Instance created"
  end

  def mail_type
    DNM::MAIL_TYPES::TRANSACTIONAL
  end

end
