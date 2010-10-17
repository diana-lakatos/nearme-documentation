class BookingMailer < ActionMailer::Base
  default_url_options[:host] = "desksnear.me"

  default :from => "noreply@desksnear.me"

  def pending_confirmation(booking)
    @booking   = booking
    @workplace = booking.workplace
    @user      = booking.user

    generate_mail("Your booking is pending confirmation")
  end

  def booking_created(booking)
    @booking   = booking
    @workplace = booking.workplace
    @user      = @workplace.creator
    @url       = dashboard_url

    generate_mail("A new booking requires your confirmation")
  end

  private
    def generate_mail(subject)
      mail :subject => "[DesksNear.Me] #{subject}",
           :to      => @user.email
    end
end
