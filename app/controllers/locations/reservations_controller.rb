module Locations
  class ReservationsController < ApplicationController
    before_filter :find_location
    before_filter :require_login_for_reservation

    # Review a reservation prior to confirmation. Same interface as create.
    def review
      @reservations = build_reservations

      render :layout => false
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
      Location.transaction do
        build_reservations.each do |reservation|
          reservation.save!
        end
      end

      render :layout => false
    rescue
      # TODO: Handle expections here
      raise
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

    def build_reservations
      reservations = []
      params[:listings].values.each { |listing_params|
        listing = @location.listings.find(listing_params[:id])
        reservation = listing.reservations.build(:user => current_user)

        listing_params[:bookings].values.each do |period|
          reservation.add_period(Date.parse(period[:date]), period[:quantity].to_i)
        end

        reservations << reservation
      }
      reservations
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
