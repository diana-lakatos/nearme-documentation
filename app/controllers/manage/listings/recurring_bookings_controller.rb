class Manage::Listings::RecurringBookingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing
  before_filter :find_recurring_booking

  def confirm
    if @recurring_booking.confirmed?
      flash[:warning] = t('flash_messages.manage.reservations.reservation_already_confirmed')
    else
      if @recurring_booking.confirm
        RecurringBookingMailer.enqueue.notify_guest_of_confirmation(@recurring_booking)
        RecurringBookingMailer.enqueue.notify_host_of_confirmation(@recurring_booking)
        notify_guest_about_recurring_booking_status_change
        event_tracker.confirmed_a_recurring_booking(@recurring_booking)
        track_recurring_booking_update_profile_informations
        event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
        flash[:success] = t('flash_messages.manage.reservations.reservation_confirmed')
      else
        flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
      end
    end
    redirect_to dashboard_host_reservations_url
  end

  def rejection_form
  end

  def reject
    if @recurring_booking.reject(rejection_reason)
      ReservationIssueLogger.rejected_with_reason @recurring_booking, current_user if rejection_reason.present?
      RecurringBookingMailer.enqueue.notify_guest_of_rejection(@recurring_booking)
      RecurringBookingMailer.enqueue.notify_host_of_rejection(@recurring_booking)
      notify_guest_about_recurring_booking_status_change
      event_tracker.rejected_a_recurring_booking(@recurring_booking)
      track_recurring_booking_update_profile_informations
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_rejected')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end
    redirect_to dashboard_host_reservations_url
    render_redirect_url_as_json if request.xhr?
  end

  def host_cancel
    if @recurring_booking.host_cancel
      RecurringBookingMailer.enqueue.notify_guest_of_cancellation_by_host(@recurring_booking)
      RecurringBookingMailer.enqueue.notify_host_of_cancellation_by_host(@recurring_booking)
      notify_guest_about_recurring_booking_status_change
      event_tracker.cancelled_a_recurring_booking(@recurring_booking, { actor: 'host' })
      track_recurring_booking_update_profile_informations
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_cancelled')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end
    redirect_to dashboard_host_reservations_url
  end

  private

  def find_listing
    @listing = current_user.listings.find(params[:listing_id])
  end

  def find_recurring_booking
    @recurring_booking = @listing.recurring_bookings.find(params[:id])
  end

  def current_event
    params[:event].downcase.to_sym
  end

  def rejection_reason
    params[:recurring_booking][:rejection_reason] if params[:recurring_booking] and params[:recurring_booking][:rejection_reason]
  end

  def notify_guest_about_recurring_booking_status_change
    RecurringBookingSmsNotifier.notify_guest_with_state_change(@recurring_booking).deliver
  end

  def track_recurring_booking_update_profile_informations
    event_tracker.updated_profile_information(@recurring_booking.owner)
    event_tracker.updated_profile_information(@recurring_booking.host)
  end
end

