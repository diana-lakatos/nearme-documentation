class ReservationMailer < DesksNearMeMailer

  def notify_guest_of_cancellation(reservation)
    setup_defaults(reservation)
    generate_mail("A booking you made has been cancelled by the owner")
  end

  def notify_guest_of_confirmation(reservation)
    setup_defaults(reservation)
    generate_mail("A booking you made has been confirmed")
  end

  def notify_guest_of_rejection(reservation)
    setup_defaults(reservation)
    generate_mail("A booking you made has been rejected")
  end

  def notify_guest_with_confirmation(reservation)
    setup_defaults(reservation)
    generate_mail("A booking you made is pending confirmation")
  end

  def notify_host_of_cancellation(reservation)
    setup_defaults(reservation)
    @user = @listing.creator
    generate_mail("A guest has cancelled a booking")
  end

  def notify_host_of_confirmation(reservation)
    setup_defaults(reservation)
    @user = @listing.creator
    generate_mail("You have confirmed a booking")
  end
  
  def notify_guest_of_expiration(reservation)
    setup_defaults(reservation)
    generate_mail("A booking you made has expired")
  end
  
  def notify_host_of_expiration(reservation)
    setup_defaults(reservation)
    @user = @listing.creator
    generate_mail("A booking for one of your listings has expired")
  end
  
  def notify_host_with_confirmation(reservation)
    setup_defaults(reservation)
    @user = @listing.creator
    @url  = manage_guests_dashboard_url(:token => @user.authentication_token)
    generate_mail("A booking requires your confirmation")
  end

  def notify_host_without_confirmation(reservation)
    setup_defaults(reservation)
    @user = @listing.creator
    @reserver = reservation.owner.name
    generate_mail("A guest has made a booking")
  end

  if defined? MailView
    class Preview < MailView

      def notify_guest_of_cancellation
        ::ReservationMailer.notify_guest_of_cancellation(Reservation.first)
      end

      def notify_guest_of_confirmation
        ::ReservationMailer.notify_guest_of_confirmation(Reservation.first)
      end

      def notify_guest_of_expiration
        ::ReservationMailer.notify_guest_of_expiration(Reservation.first)
      end

      def notify_guest_of_rejection
       ::ReservationMailer.notify_guest_of_rejection(Reservation.first)
      end

      def notify_guest_with_confirmation
        ::ReservationMailer.notify_guest_with_confirmation(Reservation.first)
      end

      def notify_host_of_cancellation
        ::ReservationMailer.notify_host_of_cancellation(Reservation.first)
      end

      def notify_host_of_confirmation
        ::ReservationMailer.notify_host_of_confirmation(Reservation.first)
      end

      def notify_host_of_expiration
        ::ReservationMailer.notify_host_of_expiration(Reservation.first)
      end

      def notify_host_with_confirmation
        ::ReservationMailer.notify_host_with_confirmation(Reservation.first)
      end

      def notify_host_without_confirmation
        ::ReservationMailer.notify_host_without_confirmation(Reservation.first)
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
           :to      => @user.email,
           :bcc     => "notifications@desksnear.me"
    end
end
