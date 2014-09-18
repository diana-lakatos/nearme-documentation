class Listings::ReservationsController < ApplicationController

  before_filter :secure_payment_with_token, :only => [:review]
  before_filter :load_payment_with_token, :only => [:review]
  before_filter :find_listing
  before_filter :find_reservation, only: [:booking_successful]
  before_filter :build_reservation_request, :only => [:review, :create, :store_reservation_request]
  before_filter :require_login_for_reservation, :only => [:review, :create]
  before_filter :find_current_country, :only => [:review, :create]
  after_filter  :clear_origin_domain, :only => [:create]

  def review
    event_tracker.reviewed_a_booking(@reservation_request.reservation)
  end

  def platform_context
    if not origin_domain?
      PlatformContext.current = PlatformContext.new(origin_domain)
    else
      super
    end
  end

  def load_payment_with_token
    if secure? && request.ssl? and params["payment_token"]
      user, reservation_params = User::PaymentTokenVerifier.find_token(params["payment_token"])
      sign_in user
      set_origin_domain(reservation_params['host'])
      params[:reservation_request] = reservation_params.symbolize_keys!
    end
  end

  def secure_payment_with_token
    if secure? && !request.ssl?
      params[:reservation_request][:host] = request.host
      verifier = User::PaymentTokenVerifier.new(current_user, params[:reservation_request])
      @token = verifier.generate
      @url = url_for(platform_context.secured_constraint)
      render 'post_redirect'
    end
  end

  def create
    @reservation = @reservation_request.reservation
    if @reservation_request.process
      if @reservation_request.confirm_reservations?

        @reservation.schedule_expiry
        ReservationMailer.enqueue.notify_host_with_confirmation(@reservation)
        ReservationMailer.enqueue.notify_guest_with_confirmation(@reservation)
        ReservationSmsNotifier.notify_host_with_confirmation(@reservation).deliver
        event_tracker.updated_profile_information(@reservation.owner)
        event_tracker.updated_profile_information(@reservation.host)
      else
        ReservationMailer.enqueue.notify_host_without_confirmation(@reservation)
        ReservationMailer.enqueue.notify_guest_of_confirmation(@reservation)
      end

      pre_booking_sending_date = (@reservation.date - 1.day).to_time_in_current_zone + 17.hours # send day before at 5pm
      if pre_booking_sending_date < Time.current.beginning_of_day
        ReservationPreBookingJob.perform_later(pre_booking_sending_date, @reservation)
      end

      if current_user.reservations.count == 1
        ReengagementOneBookingJob.perform_later(@reservation.last_date.to_time_in_current_zone + 7.days, @reservation)
      end

      event_tracker.requested_a_booking(@reservation)
      card_message = @reservation.credit_card_payment? ? t('flash_messages.reservations.credit_card_will_be_charged') : ''
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: card_message)

      if origin_domain?
        redirect_to booking_successful_reservation_url(@reservation, protocol: 'http', host: origin_domain)
      else
        redirect_to booking_successful_reservation_path(@reservation)
      end
    else
      render :review
    end
  end

  # Renders booking successful modal
  def booking_successful
  end

  def hourly_availability_schedule
    schedule = if params[:date].present?
      date = Date.parse(params[:date])
      @listing.hourly_availability_schedule(date).as_json
    end

    render :json => schedule.presence || {}
  end

  # Store the reservation request in the session so that it can be restored when returning to the listings controller.
  def store_reservation_request
    session[:stored_reservation_location_id] = @listing.location.id
    session[:stored_reservation_trigger] ||= {}
    session[:stored_reservation_trigger]["#{@listing.location.id}"] = params[:commit]

    # Marshals the booking request parameters into a better structured hash format for transmission and
    # future assignment to the Bookings JS controller.
    #
    # Returns a Hash of listing id's to hash of date & quantity values.
    #  { '123' => { 'date' => '2012-08-10', 'quantity => '1' }, ... }
    session[:stored_reservation_bookings] = {
      @listing.id => {
        :quantity => @reservation_request.reservation.quantity,
        :dates => @reservation_request.reservation.periods.map { |period| period.date.strftime('%Y-%m-%d') }
      }
    }
    head 200 if params[:action] == 'store_reservation_request'
  end

  private

  def require_login_for_reservation
    unless user_signed_in?
      store_reservation_request
      redirect_to new_user_registration_path(return_to: location_url(@listing.location, @listing, restore_reservations: true))
    end
  end

  def find_listing
    @listing = Transactable.find(params[:listing_id])
  end

  def find_reservation
    @reservation = @listing.reservations.find(params[:id])
  end

  def build_reservation_request
    attributes = params[:reservation_request] || {}
    attributes[:waiver_agreement_templates] ||= {}
    attributes[:waiver_agreement_templates] = attributes[:waiver_agreement_templates].select { |k, v| v == "1" }.keys
    @reservation_request = ReservationRequest.new(
      @listing,
      current_user,
      platform_context,
      {
        quantity: attributes[:quantity],
        dates: attributes[:dates],
        start_minute: attributes[:start_minute],
        end_minute: attributes[:end_minute],
        card_expires: attributes[:card_expires],
        card_code: attributes[:card_code],
        card_number: attributes[:card_number],
        country_name: attributes[:country_name],
        mobile_number: attributes[:mobile_number],
        waiver_agreement_templates: attributes[:waiver_agreement_templates]
      }
    )
  end

  def origin_domain?
    session[:origin_domain]
  end

  def clear_origin_domain
    session.delete(:origin_domain) if origin_domain?
  end

  def origin_domain
    session[:origin_domain] || request.host
  end

  def set_origin_domain(domain)
    session[:origin_domain] = domain
  end
end
