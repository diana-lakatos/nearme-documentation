class ReservationMailer < InstanceMailer
  layout 'mailer'

  def notify_guest_of_cancellation_by_host(reservation)
    setup_defaults(reservation)
    generate_mail("Your booking for '#{reservation.listing.name}' at #{reservation.location.street} was cancelled by the host")
  end

  def notify_guest_of_cancellation_by_guest(reservation)
    setup_defaults(reservation)
    generate_mail('You just cancelled a booking')
  end

  def notify_guest_of_confirmation(reservation)
    setup_defaults(reservation)
    generate_mail("#{reservation.owner.first_name}, your booking has been confirmed")
    attachments['booking.ics'] = {:mime_type => 'text/calendar', :content => ReservationIcsBuilder.new(reservation, reservation.owner).to_s }
  end

  def notify_guest_of_rejection(reservation)
    setup_defaults(reservation)
    generate_mail("Can we help, #{reservation.owner.first_name}?")
  end

  def notify_guest_with_confirmation(reservation)
    setup_defaults(reservation)
    generate_mail("#{reservation.owner.first_name}, your booking is pending confirmation")
  end

  def notify_host_of_cancellation_by_guest(reservation)
    setup_defaults(reservation)
    @user = @reservation.administrator
    generate_mail("#{reservation.owner.first_name.pluralize} cancelled a booking for '#{reservation.listing.name}' at #{reservation.location.street}")
  end

  def notify_host_of_cancellation_by_host(reservation)
    setup_defaults(reservation)
    @user = @reservation.administrator
    generate_mail("You just declined a booking")
  end

  def notify_host_of_confirmation(reservation)
    setup_defaults(reservation)
    @user = @reservation.administrator
    generate_mail('Thanks for confirming!')
  end

  def notify_guest_of_expiration(reservation)
    setup_defaults(reservation)
    generate_mail("Your booking for '#{reservation.listing.name}' at #{reservation.location.street} has expired")
  end

  def notify_host_of_expiration(reservation)
    setup_defaults(reservation)
    @user = @reservation.administrator
    generate_mail('A booking at one of your listings has expired')
  end

  def notify_host_of_rejection(reservation)
    setup_defaults(reservation)
    @user = @reservation.administrator
    generate_mail("Can we help, #{@user.first_name}?")
  end

  def notify_host_with_confirmation(reservation)
    setup_defaults(reservation)
    @user = @reservation.administrator
    @url  = manage_guests_dashboard_url(:token => @user.try(:temporary_token))
    generate_mail("#{reservation.owner.first_name} just booked your #{instance_bookable_noun}!")
  end

  def notify_host_without_confirmation(reservation)
    setup_defaults(reservation)
    @user = @reservation.administrator
    @url  = manage_guests_dashboard_url(:token => @user.try(:temporary_token))
    @reserver = @reservation.owner.name
    generate_mail("#{reservation.owner.first_name} just booked your #{instance_bookable_noun}!")
  end

  def pre_booking(reservation)
    setup_defaults(reservation)
    generate_mail("#{reservation.owner.first_name}, your booking is tomorrow!")
  end

  def mail_type
    DNM::MAIL_TYPES::TRANSACTIONAL
  end

  private

  def setup_defaults(reservation)
    @reservation  = reservation
    @listing      = @reservation.listing.reload
    @user         = @reservation.owner
    @host = @reservation.listing.administrator
  end

  def generate_mail(subject)
    mail to: @user.email,
         subject_locals: { reservation: @reservation, listing: @listing, user: @user, host: @host }
  end
end
