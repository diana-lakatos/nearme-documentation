module Locations
  class ReservationsController < ApplicationController
    before_filter :find_location
    before_filter :require_login_for_reservation

    # Review a reservation prior to confirmation. Same interface as create.
    def review
      @params_listings = params[:listings]
      @reservations = build_reservations(Reservation::PAYMENT_METHODS[:credit_card])

      render :layout => false
    rescue
      Rails.logger.info($!.inspect)
      raise $!.inspect
    end

    # Reserve bulk listings on a Location
    #
    # Parameters:
    #   listings: [
    #     {
    #       id: 101,
    #       bookings: [
    #         { date: 'YYYY-MM-DD', quantity: 10 },
    #         ...
    #       ]
    #     },
    #     ...
    #   ]
    def create
      @params_listings = params[:listings]
      @errors = []

      @reservations = build_reservations
      setup_credit_card_customer if using_credit_card?
      make_reservations if @errors.empty?

      if @errors.present?
        render :review, :layout => false
      else
        render :layout => false
      end
    end

    private

    def require_login_for_reservation
      unless current_user
        # Persist the reservation request so that when we return it will be restored.
        store_reservation_request
        render :login_required, :layout => false
      end
    end

    def find_location
      @location = Location.find(params[:location_id])
    end

    def build_reservations(payment_method = params[:payment_method])
      # NB: We can reserve multiple listings via the same form. The simple view doesn't allow this (single listing reservation), but the
      # advanced view does. A Reservation refers to a single listing, so we build multiple reservations - one for each Listing.
      reservations = []
      params[:listings].values.each { |listing_params|
        listing = @location.listings.find(listing_params[:id])
        reservation = listing.reservations.build(:user => current_user)

        # Assign the payment method chosen on the form to the Reservation
        reservation.payment_method = payment_method if payment_method

        listing_params[:bookings].values.each do |period|
          reservation.add_period(Date.parse(period[:date]), period[:quantity].to_i)
        end

        reservations << reservation
      }
      reservations
    end

    def using_credit_card?
      @reservations.first.credit_card_payment?
    end

    def setup_credit_card_customer
      begin
        card_details = User::BillingGateway::CardDetails.new(
          number: params[:card_number], 
          expiry_month: params[:card_expires].to_s[0,2],
          expiry_year: params[:card_expires].to_s[2,2], 
          cvc: params[:card_code]
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

    def make_reservations
      Location.transaction do
        @reservations.each do |reservation|
          reservation.save!
        end
      end
    end

    # Store the reservation request in the session so that it can be restored when returning to the listings controller.
    def store_reservation_request
      session[:stored_reservation_location_id] = @location.id
      session[:stored_reservation_bookings] = prepare_requested_bookings_json
    end

    # Marshals the booking request parameters into a better structured hash format for transmission and
    # future assignment to the Bookings JS controller.
    #
    # Returns a Hash of listing id's to hash of date & quantity values.
    #  { '123' => { 'date' => '2012-08-10', 'quantity => '1' }, ... }
    def prepare_requested_bookings_json(booking_request = params[:listings])
      Hash[
        booking_request.values.map { |hash_of_id_and_bookings| 
          [hash_of_id_and_bookings['id'], hash_of_id_and_bookings['bookings'].values]
        } 
      ] if booking_request.present?
    end
  end
end
