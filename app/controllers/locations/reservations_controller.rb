module Locations
  class ReservationsController < ApplicationController
    before_filter :find_location

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
    rescue
      # TODO: Handle expections here
      raise
    end

    private

    def find_location
      @location = Location.find(params[:location_id])
    end

    def build_reservations
      reservations = []
      params[:listings].values.each { |listing_params|
        listing = @location.listings.find(listing_params[:id])
        reservation = listing.reservations.build

        listing_params[:bookings].values.each do |period|
          reservation.add_period(period[:date], period[:quantity])
        end

        reservations << reservation
      }
      reservations
    end

  end
end
