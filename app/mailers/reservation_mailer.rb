class ReservationMailer < InstanceMailer
  layout 'mailer'

  def notify_guest_of_cancellation(request_context, reservation)
    setup_defaults(request_context, reservation)
    generate_mail('A booking you made has been cancelled by the owner')
  end

  def notify_guest_of_confirmation(request_context, reservation)
    setup_defaults(request_context, reservation)
    generate_mail('A booking you made has been confirmed')
  end

  def notify_guest_of_rejection(request_context, reservation)
    setup_defaults(request_context, reservation)
    generate_mail("A booking you made has been declined")
  end

  def notify_guest_with_confirmation(request_context, reservation)
    setup_defaults(request_context, reservation)
    generate_mail('A booking you made is pending confirmation')
  end

  def notify_host_of_cancellation(request_context, reservation)
    setup_defaults(request_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail('A guest has cancelled a booking')
  end

  def notify_host_of_confirmation(request_context, reservation)
    setup_defaults(request_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail('You have confirmed a booking')
  end

  def notify_guest_of_expiration(request_context, reservation)
    setup_defaults(request_context, reservation)
    generate_mail('A booking you made has expired')
  end
  
  def notify_host_of_expiration(request_context, reservation)
    setup_defaults(request_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail('A booking for one of your listings has expired')
  end
  
  def notify_host_with_confirmation(request_context, reservation)
    setup_defaults(request_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    @url  = manage_guests_dashboard_url(:token => @user.authentication_token)
    generate_mail('A booking requires your confirmation')
  end

  def notify_host_without_confirmation(request_context, reservation)
    setup_defaults(request_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    @url  = manage_guests_dashboard_url(:token => @user.authentication_token)
    @reserver = @reservation.owner.name
    generate_mail('A guest has made a booking')
  end

  if defined? MailView
    class Preview < MailView

      def notify_guest_of_cancellation
        ::ReservationMailer.notify_guest_of_cancellation(Controller::RequestContext.new, reservation)
      end

      def notify_guest_of_confirmation
        ::ReservationMailer.notify_guest_of_confirmation(Controller::RequestContext.new, reservation)
      end

      def notify_guest_of_expiration
        ::ReservationMailer.notify_guest_of_expiration(Controller::RequestContext.new, reservation)
      end

      def notify_guest_of_rejection
       ::ReservationMailer.notify_guest_of_rejection(Controller::RequestContext.new, reservation)
      end

      def notify_guest_with_confirmation
        ::ReservationMailer.notify_guest_with_confirmation(Controller::RequestContext.new, reservation)
      end

      def notify_host_of_cancellation
        ::ReservationMailer.notify_host_of_cancellation(Controller::RequestContext.new, reservation)
      end

      def notify_host_of_confirmation
        ::ReservationMailer.notify_host_of_confirmation(Controller::RequestContext.new, reservation)
      end

      def notify_host_of_expiration
        ::ReservationMailer.notify_host_of_expiration(Controller::RequestContext.new, reservation)
      end

      def notify_host_with_confirmation
        ::ReservationMailer.notify_host_with_confirmation(Controller::RequestContext.new, reservation)
      end

      def notify_host_without_confirmation
        ::ReservationMailer.notify_host_without_confirmation(Controller::RequestContext.new, reservation)
      end

      private

        def reservation
          Reservation.last || FactoryGirl.create(:reservation)
        end

    end
  end

  private

  def setup_defaults(request_context, reservation)
    @reservation  = reservation
    @listing      = @reservation.listing.reload
    @user         = @reservation.owner
    @host = @reservation.listing.administrator
    @request_context = request_context
  end

  def generate_mail(subject)
    @bcc ||= @request_context.contact_email

    @bcc = Array.wrap(@bcc) - [Theme::DEFAULT_EMAIL] if (Rails.env.development? || Rails.env.staging?)

    mail(to: @user.email,
         request_context: @request_context,
         bcc: @bcc,
         subject: instance_prefix(subject, @request_context))
  end

  def set_bcc_email
    @bcc = [@request_context.contact_email, @listing.location.email].uniq if @listing.location.email != @listing.administrator.email
  end

end
