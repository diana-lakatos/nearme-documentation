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
      @reservations = build_reservations

      # Set up the set up the credit card billing for the customer where applicable
      unless !@reservations.first.credit_card_payment?
        begin
          current_user.create_stripe_customer(params[:card_number], params[:card_expires], params[:card_code])
        rescue => e
          @errors << e.message
        end
      end

      # Make the reservations
      if @errors.empty?
        Location.transaction do
          @reservations.each do |reservation|
            reservation.save!
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
      # NB: We can reserve multiple listings via the same form. The simple view doesn't allow this (single listing reservation), but the
      # advanced view does. A Reservation refers to a single listing, so we build multiple reservations - one for each Listing.
      reservations = []
      params[:listings].values.each { |listing_params|
        listing = @location.listings.find(listing_params[:id])
        reservation = listing.reservations.build(:user => current_user)
        reservation.payment_method = params[:payment_method] if params[:payment_method].present?

        listing_params[:bookings].values.each do |period|
          reservation.add_period(Date.parse(period[:date]), period[:quantity].to_i)
        end

        reservations << reservation
      }
      reservations
    end

  end
end
