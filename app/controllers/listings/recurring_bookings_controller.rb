class Listings::RecurringBookingsController < ApplicationController


  before_filter :find_listing
  before_filter :require_login_for_recurring_booking, :only => [:review, :create]
  before_filter :build_recurring_booking_request, only: [:review, :create, :store_recurring_booking_request]
  before_filter :secure_payment_with_token, only: [:review]
  before_filter :load_payment_with_token, only: [:review]
  before_filter :find_recurring_booking, only: [:booking_successful]
  before_filter :find_current_country, only: [:review, :create]
  before_filter :set_section_name, only: [:review, :create]

  def review
    event_tracker.reviewed_a_recurring_booking(@recurring_booking_request.recurring_booking)
  end

  def load_payment_with_token
    if request.ssl? and params["payment_token"]
      user, recurring_booking_params = User::PaymentTokenVerifier.find_token(params["payment_token"])
      sign_in user
      params[:reservation_request] = recurring_booking_params.symbolize_keys!
    end
  end

  def secure_payment_with_token
    if require_ssl?
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
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithoutAutoConfirmation, @recurring_booking.id)
        event_tracker.updated_profile_information(@recurring_booking.owner)
        event_tracker.updated_profile_information(@recurring_booking.host)
      else
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::CreatedWithAutoConfirmation, @recurring_booking.id)
      end

      event_tracker.requested_a_recurring_booking(@recurring_booking)
      card_message = t('flash_messages.reservations.credit_card_will_be_charged')
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: card_message)

      redirect_to booking_successful_dashboard_user_recurring_booking_path(@recurring_booking)
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
        :dates => @recurring_booking_request.recurring_booking.start_on.to_date,
        :interval => @recurring_booking_request.recurring_booking.interval
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
        interval: attributes[:interval],
        schedule_params: attributes[:schedule_params],
        start_on: attributes[:start_on].to_date || attributes[:dates].try(:to_date),
        card_exp_month: attributes[:card_exp_month],
        card_exp_year: attributes[:card_exp_year],
        card_code: attributes[:card_code],
        card_number: attributes[:card_number],
        card_holder_first_name: attributes[:card_holder_first_name],
        card_holder_last_name: attributes[:card_holder_last_name],
        country_name: attributes[:country_name],
        mobile_number: attributes[:mobile_number],
        additional_charge_ids: attributes[:additional_charge_ids],
        guest_notes: attributes[:guest_notes]
      }
    )
  end

  def set_section_name
    @section_name = 'reservations reservations-review'
  end
end
