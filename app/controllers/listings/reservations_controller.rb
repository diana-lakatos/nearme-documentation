module Listings
  class ReservationsController < ApplicationController
    extend Forwardable

    before_filter :find_listing
    before_filter :build_reservation_request, :only => [:review, :create]
    before_filter :require_login_for_reservation, :only => [:review, :create, :export]

    attr_reader :listing
    def_delegators :@listing, :location
    def_delegators :@reservation_request, :reservation

    def review
      @country = request.location ? request.location.country : nil
      event_tracker.opened_booking_modal(reservation)
    end

    def create
      if @reservation_request.process
        if @reservation_request.confirm_reservations?
          ReservationMailer.notify_host_with_confirmation(reservation).deliver
          ReservationMailer.notify_guest_with_confirmation(reservation).deliver
          begin
            ReservationSmsNotifier.notify_host_with_confirmation(reservation).deliver
          rescue Twilio::REST::RequestError => e
            if e.message.include?('is not a valid phone number')
              handle_invalid_mobile_number(reservation.host)
            else
              BackgroundIssueLogger.log_issue("[auto] twilio error - #{e.message}", "support@desksnear.me", "Reservation id: #{reservation.id}, guest #{current_user.name} (#{current_user.id}). #{$!.inspect}")
            end
          end
        else
          ReservationMailer.notify_host_without_confirmation(reservation).deliver
          ReservationMailer.notify_guest_of_confirmation(reservation).deliver
        end

        event_tracker.requested_a_booking(reservation)
        flash[:notice] =  "Your reservation has been made! #{reservation.credit_card_payment? ? "Your credit card will be charged when your reservation is confirmed by the host." : "" }"

        redirect_to upcoming_reservations_path(:id => reservation)
        render_redirect_url_as_json if request.xhr?
      else
        render :review
      end
    end

    def hourly_availability_schedule
      date = if params[:date].present?
        Date.parse(params[:date]) rescue nil
      end

      schedule = if date
        listing.hourly_availability_schedule(Date.parse(params[:date])).as_json
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
        redirect_to new_user_registration_path(:return_to => location_url(listing.location, :restore_reservations => true))
      end
    end

    def find_listing
      @listing = Listing.find(params[:listing_id])
    end

    def build_reservation_request
      params[:reservation_request] ||= {}

      @reservation_request = ReservationRequest.new(
        listing,
        current_user,
        {
          :quantity       => params[:reservation_request][:quantity],
          :dates          => params[:reservation_request][:dates],
          :start_minute   => params[:reservation_request][:start_minute],
          :end_minute     => params[:reservation_request][:end_minute],
          :card_expires   => params[:reservation_request][:card_expires],
          :card_code      => params[:reservation_request][:card_code],
          :card_number    => params[:reservation_request][:card_number],
          :country_name   => params[:reservation_request][:country_name],
          :phone          => params[:reservation_request][:phone],
          :mobile_number  => params[:reservation_request][:mobile_number]
        }
      )
    end

    # Store the reservation request in the session so that it can be restored when returning to the listings controller.
    def store_reservation_request
      session[:stored_reservation_location_id] = listing.location.id

      # Marshals the booking request parameters into a better structured hash format for transmission and
      # future assignment to the Bookings JS controller.
      #
      # Returns a Hash of listing id's to hash of date & quantity values.
      #  { '123' => { 'date' => '2012-08-10', 'quantity => '1' }, ... }
      session[:stored_reservation_bookings] = {
        listing.id => {
          :quantity => reservation.quantity,
          :dates => reservation.periods.map(&:date).map { |date| date.strftime('%Y-%m-%d') }
        }
      }
    end

  end
end
