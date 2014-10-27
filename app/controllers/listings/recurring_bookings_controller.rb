class Listings::RecurringBookingsController < ApplicationController


  before_filter :find_listing
  before_filter :require_login_for_recurring_booking, :only => [:review, :create]
  before_filter :build_recurring_booking_request, only: [:review, :create, :store_recurring_booking_request]
  before_filter :redirect_if_invalid, only: [:review]
  before_filter :secure_payment_with_token, only: [:review]
  before_filter :load_payment_with_token, only: [:review]
  before_filter :find_recurring_booking, only: [:booking_successful]
  before_filter :find_current_country, only: [:review, :create]
  after_filter  :clear_origin_domain, only: [:create]
  before_filter :set_section_name, only: [:review, :create]

  def review
    event_tracker.reviewed_a_recurring_booking(@recurring_booking_request.recurring_booking)
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
      user, recurring_booking_params = User::PaymentTokenVerifier.find_token(params["payment_token"])
      sign_in user
      set_origin_domain(recurring_booking_params['host'])
      params[:reservation_request] = recurring_booking_params.symbolize_keys!
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
    @recurring_booking = @recurring_booking_request.recurring_booking
    if @recurring_booking_request.process
      if @recurring_booking_request.confirm_reservations?
        @recurring_booking.schedule_expiry
        RecurringBookingMailer.enqueue.notify_host_with_confirmation(@recurring_booking)
        RecurringBookingMailer.enqueue.notify_guest_with_confirmation(@recurring_booking)
        RecurringBookingSmsNotifier.notify_host_with_confirmation(@recurring_booking).deliver
        event_tracker.updated_profile_information(@recurring_booking.owner)
        event_tracker.updated_profile_information(@recurring_booking.host)
      else
        RecurringBookingMailer.enqueue.notify_host_without_confirmation(@recurring_booking)
        RecurringBookingMailer.enqueue.notify_guest_of_confirmation(@recurring_booking)
      end

      event_tracker.requested_a_recurring_booking(@recurring_booking)
      card_message = @recurring_booking.credit_card_payment? ? t('flash_messages.reservations.credit_card_will_be_charged') : ''
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: card_message)

      if origin_domain?
        redirect_to recurring_booking_successful_reservation_url(@recurring_booking, protocol: 'http', host: origin_domain)
      else
        redirect_to recurring_booking_successful_reservation_path(@recurring_booking)
      end
    else
      render :review
    end
  end

  def booking_successful
  end

  def hourly_availability_schedule
    schedule = if params[:date].present?
      date = Date.parse(params[:date])
      @listing.hourly_availability_schedule(date).as_json
    end

    render :json => schedule.presence || {}
  end

  # Store the recurring_booking request in the session so that it can be restored when returning to the listings controller.
  def store_recurring_booking_request
    session[:stored_recurring_booking_location_id] = @listing.location.id
    session[:stored_reservation_trigger] ||= {}
    session[:stored_reservation_trigger]["#{@listing.location.id}"] = params[:commit]

    # Marshals the booking request parameters into a better structured hash format for transmission and
    # future assignment to the Bookings JS controller.
    #
    # Returns a Hash of listing id's to hash of date & quantity values.
    #  { '123' => { 'date' => '2012-08-10', 'quantity => '1' }, ... }
    session[:stored_recurring_booking_bookings] = {
      @listing.id => {
        :quantity => @recurring_booking_request.recurring_booking.quantity,
        :schedule_params => @recurring_booking_request.recurring_booking.schedule_params,
        :start_on => @recurring_booking_request.recurring_booking.start_on.to_date,
        :end_on => @recurring_booking_request.recurring_booking.end_on.to_date,
        :start_minute => @recurring_booking_request.recurring_booking.start_minute,
        :end_minute => @recurring_booking_request.recurring_booking.end_minute
      }
    }
    head 200 if params[:action] == 'store_recurring_booking_request'
  end

  private

  def require_login_for_recurring_booking
    unless user_signed_in?
      store_recurring_booking_request
      redirect_to new_user_registration_path(return_to: location_url(@listing.location, @listing, restore_recurring_bookings: true))
    end
  end

  def find_listing
    @listing = Transactable.find(params[:listing_id])
  end

  def find_recurring_booking
    @recurring_booking = @listing.recurring_bookings.find(params[:id])
  end

  def build_recurring_booking_request
    attributes = params[:reservation_request] || {}
    @recurring_booking_request = RecurringBookingRequest.new(
      @listing,
      current_user,
      platform_context,
      {
        quantity: attributes[:quantity],
        schedule_params: attributes[:schedule_params],
        start_minute: attributes[:start_minute],
        end_minute: attributes[:end_minute],
        occurrences: attributes[:occurrences],
        start_on: attributes[:start_on].to_date,
        end_on: attributes[:end_on].to_date,
        card_expires: attributes[:card_expires],
        card_code: attributes[:card_code],
        card_number: attributes[:card_number],
        country_name: attributes[:country_name],
        mobile_number: attributes[:mobile_number]
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

  def redirect_if_invalid
    unless @recurring_booking_request.recurring_booking.at_least_one_valid_reservation
      flash[:error] = @recurring_booking_request.recurring_booking.errors[:reservations][0]
      redirect_to location_path(@listing.location)
    end
  end

  def set_section_name
    @section_name = 'reservations reservations-review'
  end
end
