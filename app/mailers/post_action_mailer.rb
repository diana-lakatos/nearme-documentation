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

  if defined? MailView
    class Preview < MailView

      def sign_up_verify
        ::PostActionMailer.sign_up_verify(PlatformContext.new, User.where('users.verified_at is null').first)
      end

      def sign_up_welcome
        ::PostActionMailer.sign_up_welcome(PlatformContext.new, User.last)
      end

      def list_draft
        ::PostActionMailer.list_draft(PlatformContext.new, user_with_listing)
      end

      def list
        ::PostActionMailer.list(PlatformContext.new, user_with_listing)
      end

      private

      def user_with_listing
        User.all.select{|u| !u.listings.count.zero?}.sample || FactoryGirl.create(:listing).user
      end
    end
  end

end
