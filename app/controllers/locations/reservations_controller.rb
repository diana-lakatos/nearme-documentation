module Locations
  class ReservationsController < ApplicationController
    before_filter :find_location
    before_filter :store_bookings_request, only: :review
    before_filter :require_login

    # Review a reservation prior to confirmation. Same interface as create.
    def review
      @params_listings = params[:listings]
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
      @params_listings = params[:listings]
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

    def require_login
      unless current_user
        render :login_required, :layout => false
      end
    end

    def find_location
      @location = Location.find(params[:location_id])
    end

    def build_reservations
      reservations = []
      @params_listings.values.each { |listing_params|
        listing = @location.listings.find(listing_params[:id])
        reservation = listing.reservations.build(:user => current_user)

        listing_params[:bookings].values.each do |period|
          reservation.add_period(Date.parse(period[:date]), period[:quantity].to_i)
        end

        reservations << reservation
      }
      reservations
    end

  end
end
