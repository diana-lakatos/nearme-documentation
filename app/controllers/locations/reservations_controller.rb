module Locations
  class ReservationsController < ApplicationController
    before_filter :find_location
    before_filter :require_login

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
      @errors = []
      @do_not_create_charge = params[:do_not_create_charge].to_i

      Location.transaction do

        build_reservations.each do |reservation|
          reservation.create_charge = !@do_not_create_charge if reservation.total_amount > 0
          reservation.save!
        end

        unless @do_not_create_charge == 1 || current_user.stripe_id
          begin
            current_user.create_stripe_customer(params[:card_number], params[:card_expires], params[:card_code])
          rescue => e
            @errors << e.message
          end
        end

      end

      if @errors.present?
        @reservations = build_reservations
        render :review, :layout => false
      else
        render :layout => false
      end

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

  end
end
