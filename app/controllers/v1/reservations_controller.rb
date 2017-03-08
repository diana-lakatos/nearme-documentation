class V1::ReservationsController < V1::BaseController
  # These endpoints require authentication
  before_filter :require_authentication

  # Be graceful when records don't exist
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Show all known reservations for the user
  def index
    @reservations = current_user.orders.reservations
    render json: @reservations
  end

  # Show all past reservations for the user.
  # Reservations are "in the past" if *all* of their dates are in the past.
  # TODO: this might be optimized by leveraging database indices
  def past
    # Get all reservations for the user
    @reservations = current_user.orders.reservations

    # Drop reservations that have a date that is not in the past
    timestamp_now = Time.zone.now

    @reservations.to_a.delete_if do |reservation|
      # Does this reservation have a date that's not in the past?
      in_the_past = true

      reservation.periods.each do |period|
        in_the_past = false if period.date.beginning_of_day >= timestamp_now
      end

      # Delete only if the reservation is not in the past
      !in_the_past
    end

    # Render JSON
    render json: @reservations
  end

  # Show all "upcoming" reservations for the user.  For those reservations
  # that are "in progress", we still show the reservation.
  # TODO: this might be optimized by leveraging database indices
  def future
    # Get all reservations the user has created
    @reservations = current_user.orders.reservations

    # Drop reservations that have all dates in the past
    timestamp_now = Time.zone.now

    @reservations.to_a.delete_if do |reservation|
      # Does this reservation have at least one date in the future?
      in_the_future = false

      reservation.periods.each do |period|
        in_the_future = true if period.date.beginning_of_day >= timestamp_now
      end

      # Delete only if the reservation is not in the future
      !in_the_future
    end

    # Render JSON
    render json: @reservations
  end

  # Show an individual reservation
  def show
    @reservation = current_user.orders.reservations.find(params[:id])
    render json: @reservation
  end

  # Cancel an individual reservation
  def destroy
    @reservation = current_user.orders.reservations.find params[:id]

    if @reservation.cancellable?

      # Notify the host of the cancelation...

      # Perform the cancelation
      @reservation.user_cancel

      head :no_content

    else

      # Reservation can't be canceled...
      e = DNM::Error.new "Reservation can't be canceled'"
      e.errors << { resource: 'Reservation',
                    field:    'cancellable',
                    code:     'not true' }
      render json: e.to_hash, status: e.status

    end
  end

  # Error handler
  def record_not_found
    e = DNM::Error.new 'Missing Reservation'
    e.errors << { resource: 'Reservation',
                  field:    'id',
                  code:     'missing' }
    render json: e.to_hash, status: e.status
  end
end
