class RecurringBookingMailer < InstanceMailer
  layout 'mailer'

  def notify_guest_of_cancellation_by_host(recurring_booking)
    setup_defaults(recurring_booking)
    generate_mail("Your recurring booking for '#{recurring_booking.listing.name}' at #{recurring_booking.location.street} was cancelled by the host")
  end

  def notify_guest_of_cancellation_by_guest(recurring_booking)
    setup_defaults(recurring_booking)
    generate_mail('You just cancelled a recurring booking')
  end

  def notify_guest_of_confirmation(recurring_booking)
    setup_defaults(recurring_booking)
    generate_mail("#{recurring_booking.owner.first_name}, your recurring booking has been confirmed")
    #attachments['booking.ics'] = {:mime_type => 'text/calendar', :content => ReservationIcsBuilder.new(recurring_booking, recurring_booking.owner).to_s }
  end

  def notify_guest_of_rejection(recurring_booking)
    setup_defaults(recurring_booking)
    generate_mail("Can we help, #{recurring_booking.owner.first_name}?")
  end

  def notify_guest_with_confirmation(recurring_booking)
    setup_defaults(recurring_booking)
    generate_mail("#{recurring_booking.owner.first_name}, your recurring booking is pending confirmation")
  end

  def notify_host_of_cancellation_by_guest(recurring_booking)
    setup_defaults(recurring_booking)
    @user = @recurring_booking.administrator
    set_bcc_email
    generate_mail("#{recurring_booking.owner.first_name.pluralize} cancelled a recurring booking for '#{recurring_booking.listing.name}' at #{recurring_booking.location.street}")
  end

  def notify_host_of_cancellation_by_host(recurring_booking)
    setup_defaults(recurring_booking)
    @user = @recurring_booking.administrator
    set_bcc_email
    generate_mail("You just declined a recurring booking")
  end

  def notify_host_of_confirmation(recurring_booking)
    setup_defaults(recurring_booking)
    @user = @recurring_booking.administrator
    set_bcc_email
    generate_mail('Thanks for confirming!')
  end

  def notify_guest_of_expiration(recurring_booking)
    setup_defaults(recurring_booking)
    generate_mail("Your recurring booking for '#{recurring_booking.listing.name}' at #{recurring_booking.location.street} has expired")
  end

  def notify_host_of_expiration(recurring_booking)
    setup_defaults(recurring_booking)
    @user = @recurring_booking.administrator
    set_bcc_email
    generate_mail('A recurring booking at one of your listings has expired')
  end

  def notify_host_of_rejection(recurring_booking)
    setup_defaults(recurring_booking)
    @user = @recurring_booking.administrator
    set_bcc_email
    generate_mail("Can we help, #{@user.first_name}?")
  end

  def notify_host_with_confirmation(recurring_booking)
    setup_defaults(recurring_booking)
    @user = @recurring_booking.administrator
    set_bcc_email
    @url  = dashboard_host_reservations_url(:token => @user.try(:temporary_token))
    generate_mail("#{recurring_booking.owner.first_name} just booked your #{instance_bookable_noun}!")
  end

  def notify_host_without_confirmation(recurring_booking)
    setup_defaults(recurring_booking)
    @user = @recurring_booking.administrator
    set_bcc_email
    @url  = dashboard_host_reservations_url(:token => @user.try(:temporary_token))
    @reserver = @recurring_booking.owner.name
    generate_mail("#{recurring_booking.owner.first_name} just booked your #{instance_bookable_noun}!")
  end

  def pre_booking(recurring_booking)
    setup_defaults(recurring_booking)
    generate_mail("#{recurring_booking.owner.first_name}, your booking is tomorrow!")
  end

  def mail_type
    DNM::MAIL_TYPES::TRANSACTIONAL
  end

  private

  def setup_defaults(recurring_booking)
    @recurring_booking  = recurring_booking
    @reservation = recurring_booking.reservations.first
    @listing      = @recurring_booking.listing.reload
    @user         = @recurring_booking.owner
    @host = @recurring_booking.listing.administrator
  end

  def generate_mail(subject)
    @bcc ||= theme_contact_email

    @bcc = Array.wrap(@bcc) - [Theme::DEFAULT_EMAIL] if (Rails.env.development? || Rails.env.staging?)

    mail to: @user.email,
         bcc: @bcc,
         subject_locals: { reservation: @reservation, listing: @listing, user: @user, host: @host }
  end

  def set_bcc_email
    @bcc = @listing.location.email if @listing.location.email != @recurring_booking.administrator.try(:email)
  end

end
