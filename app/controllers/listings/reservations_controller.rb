module Listings
  class ReservationsController < ApplicationController
    before_filter :find_listing
    before_filter :build_reservation, :only => [:review, :create]
    before_filter :require_login_for_reservation, :only => [:review, :create]

    def review
      @reservation.payment_method = Reservation::PAYMENT_METHODS[:credit_card]
      event_tracker.opened_booking_modal(@reservation)
    end

    def create
      @errors = []
      setup_credit_card_customer if using_credit_card?

      if @errors.empty? && @reservation.save
        if @reservation.listing.confirm_reservations?
          ReservationMailer.notify_host_with_confirmation(@reservation).deliver
          ReservationMailer.notify_guest_with_confirmation(@reservation).deliver
          ReservationSmsNotifier.notify_host_with_confirmation(@reservation).deliver
        else
          ReservationMailer.notify_host_without_confirmation(@reservation).deliver
          ReservationMailer.notify_guest_of_confirmation(@reservation).deliver
        end
        event_tracker.requested_a_booking(@reservation)

        flash[:notice] =  "Your reservation has been made! #{@reservation.credit_card_payment? ? "Your credit card will be charged when your reservation is confirmed by the host." : "" }"

        redirect_to upcoming_reservations_path(:id => @reservation)
        render_redirect_url_as_json if request.xhr? 
      else
        render :review
      end
    end

    def export
      @reservation = current_user.reservations.find(params[:id])
      respond_to do |format|
        format.ics do
          calendar = Icalendar::Calendar.new
          @reservation.periods.each do |period|
            calendar.add_event(period.to_ics)
          end
          calendar.publish
          render :text => calendar.to_ical
        end
      end
    end

    def hourly_availability_schedule
      date = if params[:date].present?
        Date.parse(params[:date]) rescue nil
      end

      schedule = if date
        @listing.hourly_availability_schedule(Date.parse(params[:date])).as_json
      else
        {}
      end

      render :json => schedule
    end

    private

    def require_login_for_reservation
      unless current_user
        # Persist the reservation request so that when we return it will be restored.
        store_reservation_request
        redirect_to new_user_registration_path(:return_to => location_url(@listing.location, :restore_reservations => true))
      end
    end

    def find_listing
      @listing = Listing.find(params[:listing_id])
      @location = @listing.location
    end

    def build_reservation
      @reservation = @listing.reservations.build
      @reservation.user = current_user if current_user
      @reservation.quantity = params[:reservation][:quantity]

      # Assign the payment method chosen on the form to the Reservation
      @reservation.payment_method = params[:payment_method] if params[:payment_method].present?

      if @listing.hourly_reservations?
        start_minute = params[:reservation][:start_minute].try(:to_i)
        end_minute   = params[:reservation][:end_minute].try(:to_i)
      end

      params[:reservation][:dates].each do |date_str|
        @reservation.add_period(Date.parse(date_str), start_minute, end_minute)
      end

      @reservation
    end

    def using_credit_card?
      @reservation.credit_card_payment?
    end

    def setup_credit_card_customer
      begin
        params[:card_expires] = params[:card_expires].to_s.strip
        card_details = User::BillingGateway::CardDetails.new(
          number: params[:card_number].to_s,
          expiry_month: params[:card_expires].to_s[0,2],
          expiry_year: params[:card_expires].to_s[-2,2],
          cvc: params[:card_code].to_s
        )

        if card_details.valid?
          current_user.billing_gateway.store_card(card_details)
        else
          @errors << "Those credit card details don't look valid"
        end
      rescue User::BillingGateway::BillingError => e
        @errors << e.message
      end
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
          :quantity => @reservation.quantity,
          :dates => @reservation.periods.map(&:date).map { |date| date.strftime('%Y-%m-%d') }
        }
      }
    end
  end
end
