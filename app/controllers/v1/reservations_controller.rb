class V1::ReservationsController < V1::BaseController

  # These endpoints require authentication
  before_filter :require_authentication

  # Be graceful when records don't exist
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found


  # Show all known reservations for the user
  def index
    @reservations = current_user.reservations
    render json: @reservations
  end


  # Show all past reservations for the user.
  # Reservations are "in the past" if *all* of their dates are in the past.
  # TODO: this might be optimized by leveraging database indices
  def past

    # Get all reservations for the user
    @reservations = current_user.reservations

    # Drop reservations that have a date that is not in the past
    timestamp_now = Time.now.utc

    @reservations.delete_if { |reservation|

      # Does this reservation have a date that's not in the past?
      in_the_past = true

      reservation.periods.each { |period|
        in_the_past = false if period.date.to_time.utc >= timestamp_now
      }

      # Delete only if the reservation is not in the past
      !in_the_past
    }

    # Render JSON
    render json: @reservations

  end


  # Show all "upcoming" reservations for the user.  For those reservations
  # that are "in progress", we still show the reservation.
  # TODO: this might be optimized by leveraging database indices
  def future

    # Get all reservations the user has created
    @reservations = current_user.reservations

    # Drop reservations that have all dates in the past
    timestamp_now = Time.now.utc

    @reservations.delete_if { |reservation|

      # Does this reservation have at least one date in the future?
      in_the_future = false

      reservation.periods.each { |period|
        in_the_future = true if period.date.to_time.utc >= timestamp_now
      }

      # Delete only if the reservation is not in the future
      !in_the_future
    }

    # Render JSON
    render json: @reservations

  end


  # Show an individual reservation
  def show

    @reservation = current_user.reservations.find(params[:id])
    render json: @reservation

  end


  # Cancel an individual reservation
  def destroy

    @reservation = current_user.reservations.find params[:id]

    if @reservation.cancelable

      # Notify the host of the cancelation...

      # Perform the cancelation
      @reservation.state = 'canceled'
      @reservation.save!

      head :no_content

    else

      # Reservation can't be canceled...
      e = DNM::Error.new "Reservation can't be canceled'"
      e.errors << { resource: "Reservation",
                    field:    "cancelable",
                    code:     "not true" }
      render json: e.to_hash, status: e.status

    end

  end


  # Error handler
  def record_not_found

    e = DNM::Error.new "Missing Reservation"
    e.errors << { resource: "Reservation",
                  field:    "id",
                  code:     "missing" }
    render json: e.to_hash, status: e.status

  end

end
