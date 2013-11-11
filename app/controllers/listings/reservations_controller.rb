class Listings::ReservationsController < ApplicationController

  before_filter :find_listing
  before_filter :find_reservation, only: [:booking_successful]
  before_filter :build_reservation_request, :only => [:review, :create]
  before_filter :require_login_for_reservation, :only => [:review, :create]

  def review
    @country = request.location.try(:country)
    event_tracker.opened_booking_modal(Analytics::EventTracker.serialize_object(@reservation_request.reservation))
  end

  def create
    @reservation = @reservation_request.reservation
    if @reservation_request.process
      if @reservation_request.confirm_reservations?

        @reservation.schedule_expiry(platform_context)
        ReservationMailer.enqueue.notify_host_with_confirmation(platform_context, @reservation)
        ReservationMailer.enqueue.notify_guest_with_confirmation(platform_context, @reservation)
        begin
          ReservationSmsNotifier.notify_host_with_confirmation(@reservation).deliver
        rescue Twilio::REST::RequestError => e
          if e.message.include?('is not a valid phone number')
            @reservation.host.notify_about_wrong_phone_number(platform_context)
          else
            BackgroundIssueLogger.log_issue("[internal] twilio error - #{e.message}", "support@desksnear.me", "Reservation id: #{@reservation.id}, guest #{current_user.name} (#{current_user.id}). #{$!.inspect}")
          end
        end
        event_tracker.updated_profile_information(@reservation.owner)
        event_tracker.updated_profile_information(@reservation.host)
      else
        ReservationMailer.enqueue.notify_host_without_confirmation(platform_context, @reservation)
        ReservationMailer.enqueue.notify_guest_of_confirmation(platform_context, @reservation)
      end

      pre_booking_sending_date = (@reservation.date - 1.day).to_time_in_current_zone + 17.hours # send day before at 5pm
      if pre_booking_sending_date < Time.current.beginning_of_day
        ReservationPreBookingJob.perform_later(pre_booking_sending_date, platform_context, @reservation)
      end

      if current_user.reservations.count == 1
        ReengagementOneBookingJob.perform_later(@reservation.last_date.to_time_in_current_zone + 7.days, platform_context, @reservation)
      end

      event_tracker.requested_a_booking(@reservation)
      card_message = @reservation.credit_card_payment? ? t('flash_messages.reservations.credit_card_will_be_charged') : ''
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: card_message)
      redirect_to booking_successful_reservation_path(@reservation)
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

  private

  def require_login_for_reservation
    unless user_signed_in?
      store_reservation_request
      redirect_to new_user_registration_path(return_to: location_listing_url(@listing.location, @listing, restore_reservations: true))
    end
  end

  def find_listing
    @listing = Listing.find(params[:listing_id])
  end

  def find_reservation
    @reservation = @listing.reservations.find(params[:id])
  end

  def build_reservation_request
    attributes = params[:reservation_request] || {}

    @reservation_request = ReservationRequest.new(
      @listing,
      current_user,
      {
        :quantity       => attributes[:quantity],
        :dates          => attributes[:dates],
        :start_minute   => attributes[:start_minute],
        :end_minute     => attributes[:end_minute],
        :card_expires   => attributes[:card_expires],
        :card_code      => attributes[:card_code],
        :card_number    => attributes[:card_number],
        :country_name   => attributes[:country_name],
        :phone          => attributes[:phone],
        :mobile_number  => attributes[:mobile_number]
      }
    )
  end

  # Store the reservation request in the session so that it can be restored when returning to the listings controller.
  def store_reservation_request
    session[:stored_reservation_location_id] = @listing.location.id

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
  end

end
