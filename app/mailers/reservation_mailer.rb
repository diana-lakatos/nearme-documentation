class ReservationMailer < InstanceMailer
  layout 'mailer'

  def notify_guest_of_cancellation(reservation_id)
    setup_defaults(reservation_id)
    generate_mail('A booking you made has been cancelled by the owner')
  end

  def notify_guest_of_confirmation(reservation_id)
    setup_defaults(reservation_id)
    generate_mail('A booking you made has been confirmed')
  end

  def notify_guest_of_rejection(reservation_id)
    setup_defaults(reservation_id)
    generate_mail("A booking you made has been declined")
  end

  def notify_guest_with_confirmation(reservation_id)
    setup_defaults(reservation_id)
    generate_mail('A booking you made is pending confirmation')
  end

  def notify_host_of_cancellation(reservation_id)
    setup_defaults(reservation_id)
    @user = @listing.creator
    generate_mail('A guest has cancelled a booking')
  end

  def notify_host_of_confirmation(reservation_id)
    setup_defaults(reservation_id)
    @user = @listing.creator
    generate_mail('You have confirmed a booking')
  end

  def notify_guest_of_expiration(reservation_id)
    setup_defaults(reservation_id)
    generate_mail('A booking you made has expired')
  end
  
  def notify_host_of_expiration(reservation_id)
    setup_defaults(reservation_id)
    @user = @listing.creator
    generate_mail('A booking for one of your listings has expired')
  end
  
  def notify_host_with_confirmation(reservation_id)
    setup_defaults(reservation_id)
    @user = @listing.creator
    @url  = manage_guests_dashboard_url(:token => @user.authentication_token)
    generate_mail('A booking requires your confirmation')
  end

  def notify_host_without_confirmation(reservation_id)
    setup_defaults(reservation_id)
    @user = @listing.creator
    @url  = manage_guests_dashboard_url(:token => @user.authentication_token)
    @reserver = @reservation.owner.name
    generate_mail('A guest has made a booking')
  end

  if defined? MailView
    class Preview < MailView

      def notify_guest_of_cancellation
        ::ReservationMailer.notify_guest_of_cancellation(reservation.id)
      end

      def notify_guest_of_confirmation
        ::ReservationMailer.notify_guest_of_confirmation(reservation.id)
      end

      def notify_guest_of_expiration
        ::ReservationMailer.notify_guest_of_expiration(reservation.id)
      end

      def notify_guest_of_rejection
       ::ReservationMailer.notify_guest_of_rejection(reservation.id)
      end

      def notify_guest_with_confirmation
        ::ReservationMailer.notify_guest_with_confirmation(reservation.id)
      end

      def notify_host_of_cancellation
        ::ReservationMailer.notify_host_of_cancellation(reservation.id)
      end

      def notify_host_of_confirmation
        ::ReservationMailer.notify_host_of_confirmation(reservation.id)
      end

      def notify_host_of_expiration
        ::ReservationMailer.notify_host_of_expiration(reservation.id)
      end

      def notify_host_with_confirmation
        ::ReservationMailer.notify_host_with_confirmation(reservation.id)
      end

      def notify_host_without_confirmation
        ::ReservationMailer.notify_host_without_confirmation(reservation.id)
      end

      private

        def reservation
          Reservation.last || FactoryGirl.create(:reservation)
        end

    end
  end

  private

  def setup_defaults(reservation_id)
    @reservation  = Reservation.find(reservation_id)
    @listing      = @reservation.listing.reload
    @user         = @reservation.owner
  end

  def generate_mail(subject)
    instance = @listing.instance

    mail(to: @user.email,
         instance: instance,
         subject: instance_prefix(subject, instance))
  end
end
