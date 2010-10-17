class BookingMailer < ActionMailer::Base
  default_url_options[:host] = "desksnear.me"

  default :from => "noreply@desksnear.me"

  def pending_confirmation(booking)
    setup_defaults(booking)
    generate_mail("Your booking is pending confirmation")
  end

  def booking_confirmed(booking)
    setup_defaults(booking)
    generate_mail("Your booking has been confirmed")
  end

  def unconfirmed_booking_created(booking)
    setup_defaults(booking)

    @user = @workplace.creator
    @url  = dashboard_url

    generate_mail("A new booking requires your confirmation")
  end

  def confirmed_booking_created(booking)
    setup_defaults(booking)
    @user = @workplace.creator
    generate_mail("You have a new booking")
  end

  private
    def setup_defaults(booking)
      @booking   = booking
      @workplace = booking.workplace
      @user      = booking.user
    end

    def generate_mail(subject)
      mail :subject => "[DesksNear.Me] #{subject}",
           :to      => @user.email
    end
end
