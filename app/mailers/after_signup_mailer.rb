class AfterSignupMailer < InstanceMailer

  helper SharingHelper

  layout false

  def help_offer(theme, user)
    @user = user
    @theme = theme
    @instance = theme.instance
    @location = @user.locations.first

    @sent_by = 'Michelle R'

    mail(to: @user.email,
         template_name: choose_template,
         theme: @theme,
         subject: "Welcome to DesksNear.me")
  end

  if defined? MailView
    class Preview < MailView

      def help_offer_with_listing
        @user = User.all.detect { |u| !u.listings.empty?  }
        @theme = Theme.first
        ::AfterSignupMailer.help_offer(@theme, @user)
      end

      def help_offer_with_booking
        @user = User.all.detect { |u| !u.reservations.empty? && u.listings.empty? }
        @theme = Theme.first
        raise "No user with booking and without listing" unless @user
        ::AfterSignupMailer.help_offer(@theme, @user)
      end

      def help_offer_without_listing_and_booking
        @user = User.all.detect { |u| u.listings.empty? && u.reservations.empty? }
        @theme = Theme.first
        raise "No user without listing and without reservation" unless @user
        ::AfterSignupMailer.help_offer(@theme, @user)
      end

    end
  end

  private

  def choose_template
    if @user.listings.empty?
      @user.reservations.empty? ? :user_without_listing_and_booking : :user_with_booking
    else
      :user_with_listing
    end
  end

end
