class AfterSignupMailer < InstanceMailer

  helper SharingHelper

  layout false

  def help_offer(user_id)
    @user = User.find(user_id)

    @location = @user.locations.first
    @instance = @user.instance

    @sent_by = 'Michelle R'

    template = choose_template

    mailer = @instance.find_mailer_for(self, template: choose_template)

    mail to:    @user.email,
      bcc:      mailer.bcc,
      reply_to: mailer.reply_to,
      from:     mailer.from,
      reply_to: mailer.reply_to,
      subject:  mailer.subject do |format| # "Welcome to DesksNear.me" do |format|
        format.html { render choose_template, instance: @instance }
        format.text { render choose_template, instance: @instance }
      end
  end

  if defined? MailView
    class Preview < MailView

      def help_offer_with_listing
        @user = User.all.detect { |u| !u.listings.empty?  }
        ::AfterSignupMailer.help_offer(@user.id)
      end

      def help_offer_with_booking
        @user = User.all.detect { |u| !u.reservations.empty? && u.listings.empty? }
        raise "No user with booking and without listing" unless @user
        ::AfterSignupMailer.help_offer(@user.id)
      end

      def help_offer_without_listing_and_booking
        @user = User.all.detect { |u| u.listings.empty? && u.reservations.empty? }
        raise "No user without listing and without reservation" unless @user
        ::AfterSignupMailer.help_offer(@user.id)
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
