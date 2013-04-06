class AfterSignupMailer < DesksNearMeMailer

  helper SharingHelper

  layout false


  def help_offer(user_id)
    @user = User.find(user_id)
    @sent_by = 'Michelle R'

    mail to:      @user.email,
      from: "micheller@desksnear.me",
      reply_to: "micheller@desksnear.me",
      subject: "Welcome to DesksNear.me",
      template_name: choose_template
  end

  if defined? MailView
    class Preview < MailView

      def help_offer_with_listing
        ::AfterSignupMailer.help_offer(User.first)
      end

      def help_offer_without_listing
        @user = User.all.detect { |u| u.listings.empty? }
        raise "No user without listing" unless @user
        ::AfterSignupMailer.help_offer(@user)
      end

    end
  end

  private

  def choose_template
    @user.listings.empty? ? :help_with_listing : :further_help
  end

end
