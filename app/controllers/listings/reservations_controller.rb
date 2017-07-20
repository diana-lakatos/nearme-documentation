# frozen_string_literal: true
module Listings
  class ReservationsController < ApplicationController
    skip_before_action :filter_out_token, only: [:return_express_checkout, :cancel_express_checkout]
    skip_before_action :log_out_if_token_exists, only: [:return_express_checkout, :cancel_express_checkout]

    def hourly_availability_schedule
      render json: schedule_from_params.presence || {}
    end

    def detect_overlapping
      service = OverlapingReservationsService.new(listing, params.slice(:date))

      if service.valid?
        render json: {}
      else
        render json: { warnings: service.warnings }
      end
    end

    private

    def listing
      @listing ||= Transactable.find(params[:listing_id])
    end

    def schedule_from_params
      # We check the action type; the user may be working with an outdated
      # transactable using a different action type
      return if params[:date].blank? || !listing.action_type.is_a?(Transactable::TimeBasedBooking)

      date = Date.parse(params[:date])
      listing.action_type.hourly_availability_schedule(date).as_json
    end
  end
end
