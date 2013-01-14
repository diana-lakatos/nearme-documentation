class ReservationMailer < DesksNearMeMailer

  def notify_guest_with_confirmation(reservation)
    setup_defaults(reservation)
    generate_mail("Your reservation is pending confirmation")
  end

  def notify_guest_of_confirmation(reservation)
    setup_defaults(reservation)
    generate_mail("Your reservation has been confirmed")
  end

  def notify_host_with_confirmation(reservation)
    setup_defaults(reservation)

    @user = @listing.creator
    @url  = dashboard_url

    generate_mail("A new reservation requires your confirmation")
  end

  def notify_host_without_confirmation(reservation)
    setup_defaults(reservation)
    @user = @listing.creator
    @reserver = reservation.owner.name
    generate_mail("You have a new reservation")
  end

  def notify_guest_of_rejection(reservation)
    setup_defaults(reservation)
    generate_mail("Sorry, your reservation at #{@listing} has been rejected")
  end

  def notify_guest_of_cancellation(reservation)
    setup_defaults(reservation)
    generate_mail("Your reservation at #{@listing} has been cancelled by the owner")
  end

  def notify_host_of_cancellation(reservation)
    setup_defaults(reservation)
    @user = @listing.creator
    generate_mail("A reservation has been cancelled")
  end

  if defined? MailView
    class Preview < MailView

      def notify_guest_with_confirmation
        ::ReservationMailer.notify_guest_with_confirmation(Reservation.first)
      end

      def notify_guest_of_confirmation
        ::ReservationMailer.notify_guest_of_confirmation(Reservation.first)
      end

      def notify_host_with_confirmation
        ::ReservationMailer.notify_host_with_confirmation(Reservation.first)
      end

      def notify_host_without_confirmation
        ::ReservationMailer.notify_host_without_confirmation(Reservation.first)
      end

      def notify_guest_of_rejection
       ::ReservationMailer.notify_guest_of_rejection(Reservation.first)
      end

      def notify_guest_of_cancellation
        ::ReservationMailer.notify_guest_of_cancellation(Reservation.first)
      end

      def notify_host_of_cancellation
        ::ReservationMailer.notify_host_of_cancellation(Reservation.first)
      end

    end
  end

  private
    def setup_defaults(reservation)
      @reservation  = reservation
      @listing      = reservation.listing
      @user         = reservation.owner
    end

    def generate_mail(subject)
      mail :subject => "[Desks Near Me] #{subject}",
           :to      => @user.email
    end
end
