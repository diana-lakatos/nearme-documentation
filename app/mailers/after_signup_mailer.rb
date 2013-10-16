class AfterSignupMailer < InstanceMailer

  helper SharingHelper
  layout false

  PERSONABLE_EMAIL = "micheller@desksnear.me"

  def help_offer(request_context, user)
    @user = user
    @request_context = request_context
    @location = @user.locations.first

    @sent_by = 'Michelle R'

    mail(to: @user.email,
         from: PERSONABLE_EMAIL,
         template_name: choose_template,
         request_context: @request_context,
         subject: "Welcome to DesksNear.me")
  end

  if defined? MailView
    class Preview < MailView

      def help_offer_with_listing
        @user = User.all.detect { |u| !u.listings.empty?  }
        ::AfterSignupMailer.help_offer(Controller::RequestContext.new, @user)
      end

      def help_offer_with_booking
        user_from_db = User.all.detect { |u| !u.reservations.empty? && u.listings.empty? }

        unless user_from_db
          @user = FactoryGirl.create(:user, email: "test_user_#{rand(100)}@example.com")
          @reservation = FactoryGirl.create(:reservation, currency: 'USD', listing: Listing.first, user: @user)
          @reservation.user = @user
        else
          @user = user_from_db
        end
        mailer = ::AfterSignupMailer.help_offer(Controller::RequestContext.new, @user)

        unless user_from_db
          @user.destroy!
          @reservation.destroy!
        end

        mailer
      end

      def help_offer_without_listing_and_booking
        user_from_db = User.all.detect { |u| u.listings.empty? && u.reservations.empty? }
        @user = user_from_db || FactoryGirl.create(:user, email: "test_user_#{rand(100)}@example.com")

        mailer = ::AfterSignupMailer.help_offer(Controller::RequestContext.new, @user)

        @user.destroy! unless user_from_db

        mailer
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
