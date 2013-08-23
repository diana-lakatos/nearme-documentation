class Manage::Listings::ReservationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing
  before_filter :find_reservation

  def confirm
    if @reservation.confirm
      ReservationMailer.notify_guest_of_confirmation(@reservation).deliver
      ReservationMailer.notify_host_of_confirmation(@reservation).deliver
      event_tracker.confirmed_a_booking(@reservation)
      event_tracker.updated_profile_information(@reservation.owner)
      event_tracker.updated_profile_information(@reservation.host)
      flash[:success] = "You have confirmed the reservation!"
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to manage_guests_dashboard_url
  end

  def rejection_form
  end

  def reject
    if @reservation.reject(rejection_reason)
      ReservationIssueLogger.rejected_with_reason @reservation, current_user if rejection_reason.present?
      ReservationMailer.notify_guest_of_rejection(@reservation).deliver
      event_tracker.rejected_a_booking(@reservation)
      event_tracker.updated_profile_information(@reservation.owner)
      event_tracker.updated_profile_information(@reservation.host)
      flash[:deleted] = "You have rejected the reservation. Maybe next time!"
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to manage_guests_dashboard_url
    render_redirect_url_as_json if request.xhr?
  end

  def host_cancel
    if @reservation.host_cancel
      ReservationMailer.notify_guest_of_cancellation(@reservation).deliver
      event_tracker.cancelled_a_booking(@reservation, { actor: 'host' })
      event_tracker.updated_profile_information(@reservation.owner)
      event_tracker.updated_profile_information(@reservation.host)
      flash[:deleted] = "You have cancelled this reservation."
    else
      flash[:error] = "Your reservation could not be confirmed."
    end
    redirect_to manage_guests_dashboard_url
  end

  private

  def find_listing
    @listing = current_user.listings.find(params[:listing_id])
  end

  def find_reservation
    @reservation = @listing.reservations.find(params[:id])
  end

  def current_event
    params[:event].downcase.to_sym
  end

  def rejection_reason
    params[:reservation][:rejection_reason] if params[:reservation] and params[:reservation][:rejection_reason]
  end
end

