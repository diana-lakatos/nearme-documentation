class Dashboard::Company::HostRecurringBookingsController < Dashboard::Company::BaseController
  before_filter :find_listing, except: [:show, :index]
  before_filter :find_recurring_booking, except: [:show, :index]

  def index
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  # Originally in Manage::RecurringBookingsController
  def show
    if current_user.companies.any?
      @locations  = current_user.companies.first.locations
    else
      @locations = []
    end

    @recurring_booking = current_user.listing_recurring_bookings.find(params[:id]).decorate
    @guest_list = Controller::GuestList.new(current_user, @recurring_booking).filter(params[:state])
  end

  def confirm
    if @recurring_booking.confirmed?
      flash[:warning] = t('flash_messages.manage.reservations.reservation_already_confirmed')
    else
      if @recurring_booking.confirm
        event_tracker.confirmed_a_recurring_booking(@recurring_booking)
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, @recurring_booking.id)
        track_recurring_booking_update_profile_informations
        event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
        if @recurring_booking.reload.paid_until.present?
          flash[:success] = t('flash_messages.manage.reservations.reservation_confirmed')
        else
          @recurring_booking.overdue!
          flash[:warning] = t('flash_messages.manage.reservations.reservation_confirmed_but_not_charged')
        end
      else
        flash[:error] = [
          t('flash_messages.manage.reservations.reservation_not_confirmed'),
          *@recurring_booking.errors.full_messages
        ].join(' ')
      end
    end
    redirect_to :back
  end

  def rejection_form
    render layout: false
  end

  def reject
    if @recurring_booking.reject(rejection_reason)
      event_tracker.rejected_a_recurring_booking(@recurring_booking)
      track_recurring_booking_update_profile_informations
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_rejected')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end
    redirect_to :back
    render_redirect_url_as_json if request.xhr?
  end

  def host_cancel
    if @recurring_booking.host_cancel
      event_tracker.cancelled_a_recurring_booking(@recurring_booking, actor: 'host')
      track_recurring_booking_update_profile_informations
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_cancelled')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end
    redirect_to :back
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
    params[:recurring_booking][:rejection_reason] if params[:recurring_booking] && params[:recurring_booking][:rejection_reason]
  end

  def track_recurring_booking_update_profile_informations
    event_tracker.updated_profile_information(@recurring_booking.owner)
    event_tracker.updated_profile_information(@recurring_booking.host)
  end

  def workflow_alerts_hash
    {
      enquirer: @recurring_booking.owner,
      lister: @recurring_booking.host,
      data: { recurring_booking: @recurring_booking.id, listing: @recurring_booking.listing.id, reservation: recurring_booking.reservations.first.id }
    }
  end
end
