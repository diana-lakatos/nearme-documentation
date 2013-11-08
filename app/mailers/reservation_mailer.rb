class ReservationMailer < InstanceMailer
  layout 'mailer'

  def notify_guest_of_cancellation_by_host(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    generate_mail("Your booking for '#{reservation.listing.name}' at #{reservation.location.street} was cancelled by the host")
  end

  def notify_guest_of_cancellation_by_guest(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    generate_mail('You just cancelled a booking')
  end

  def notify_guest_of_confirmation(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    generate_mail("#{reservation.owner.first_name}, your booking has been confirmed")
    attachments['booking.ics'] = {:mime_type => 'text/calendar', :content => ReservationIcsBuilder.new(reservation, reservation.owner).to_s }
  end

  def notify_guest_of_rejection(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    generate_mail("Can we help, #{reservation.owner.first_name}?")
  end

  def notify_guest_with_confirmation(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    generate_mail("#{reservation.owner.first_name}, your booking is pending confirmation")
  end

  def notify_host_of_cancellation_by_guest(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail("#{reservation.owner.first_name.pluralize} cancelled a booking for '#{reservation.listing.name}' at #{reservation.location.street}")
  end

  def notify_host_of_cancellation_by_host(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail("You just declined a booking")
  end

  def notify_host_of_confirmation(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail('Thanks for confirming!')
  end

  def notify_guest_of_expiration(platform_context,reservation)
    setup_defaults(platform_context,reservation)
    generate_mail("Your booking for '#{reservation.listing.name}' at #{reservation.location.street} has expired")
  end
  
  def notify_host_of_expiration(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail('A booking at one of your listings has expired')
  end

  def notify_host_of_rejection(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    generate_mail("Can we help, #{@user.first_name}?")
  end
  
  def notify_host_with_confirmation(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    @url  = manage_guests_dashboard_url(:token => @user.authentication_token)
    generate_mail("#{reservation.owner.first_name} just booked your space!")
  end

  def notify_host_without_confirmation(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    @user = @listing.administrator
    set_bcc_email
    @url  = manage_guests_dashboard_url(:token => @user.authentication_token)
    @reserver = @reservation.owner.name
    generate_mail("#{reservation.owner.first_name} just booked your space!")
  end

  def pre_booking(platform_context, reservation)
    setup_defaults(platform_context, reservation)
    generate_mail("#{reservation.owner.first_name}, your booking is tomorrow!")
  end

  private

  def setup_defaults(platform_context, reservation)
    @reservation  = reservation
    @listing      = @reservation.listing.reload
    @user         = @reservation.owner
    @host = @reservation.listing.administrator
    @platform_context = platform_context
    @platform_context_decorator = platform_context.decorate
  end

  def generate_mail(subject)
    @bcc ||= @platform_context_decorator.contact_email

    @bcc = Array.wrap(@bcc) - [Theme::DEFAULT_EMAIL] if (Rails.env.development? || Rails.env.staging?)

    mail(to: @user.email,
         platform_context: @platform_context,
         bcc: @bcc,
         subject: instance_prefix(subject, @platform_context_decorator))
  end

  def set_bcc_email
    @bcc = [@platform_context_decorator.contact_email, @listing.location.email].uniq if @listing.location.email != @listing.administrator.email
  end

end
