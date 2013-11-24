class PostActionMailer < InstanceMailer
  helper SharingHelper

  layout 'mailer' 

  PERSONABLE_EMAIL = "micheller@desksnear.me"

  def sign_up_verify(platform_context, user)
    @user = user
    @platform_context = platform_context

    unless @user.verified_at
      mail to: @user.email, 
           subject: "#{@user.first_name}, please verify your #{@platform_context.decorate.name} email",
           platform_context: @platform_context
    end
  end

  def sign_up_welcome(platform_context, user)
    @user = user
    @platform_context = platform_context
    @platform_context_decorator = @platform_context.decorate
    @location = @user.locations.first

    mail(to: @user.email,
         from: PERSONABLE_EMAIL,
         platform_context: @platform_context,
         subject: "#{@user.first_name }, welcome to #{@platform_context_decorator.name }!")
  end

  def created_by_instance_admin(platform_context, new_user, creator)
    @new_user = new_user
    @platform_context = platform_context
    @platform_context_decorator = @platform_context.decorate
    @creator = creator

    mail(to: @new_user.email,
         platform_context: @platform_context,
         subject: "#{@new_user.first_name }, you were invited to #{@platform_context_decorator.name } by #{@creator.name}!")
  end

  def list_draft(platform_context, user)
    @user = user
    @platform_context = platform_context

    mail to: @user.email, 
           subject: "You're almost ready for your first guests!",
           platform_context: @platform_context
  end

  def list(platform_context, user)
    @user = user
    @listing = @user.listings.first
    @platform_context = platform_context

    mail to: @user.email, 
           subject: "#{@user.first_name}, your new listing looks amazing!",
           platform_context: @platform_context
  end

  def mail_type
    DNM::MAIL_TYPES::TRANSACTIONAL
  end

end
