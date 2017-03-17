# frozen_string_literal: true
class Dashboard::Company::HostRecurringBookingsController < Dashboard::Company::BaseController
  before_action :find_listing, except: [:show, :index]
  before_action :find_recurring_booking, except: [:show, :index]

  def index
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
  end

  # Originally in Manage::RecurringBookingsController
  def show
    @locations = if current_user.companies.any?
                   current_user.companies.first.locations
                 else
                   []
                 end

    @recurring_booking = current_user.listing_recurring_bookings.find(params[:id]).decorate
    @guest_list = Controller::GuestList.new(current_user, @recurring_booking).filter(params[:state])
  end

  def confirm
    if @recurring_booking.confirmed?
      flash[:warning] = t('flash_messages.manage.reservations.reservation_already_confirmed')
    else
      if @recurring_booking.confirm
        WorkflowStepJob.perform(WorkflowStep::RecurringBookingWorkflow::ManuallyConfirmed, @recurring_booking.id, as: current_user)
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

    redirect_back_or_default
  end

  def rejection_form
    render layout: false
  end

  def reject
    if @recurring_booking.reject(rejection_reason)
      flash[:deleted] = t('flash_messages.manage.reservations.reservation_rejected')
    else
      flash[:error] = t('flash_messages.manage.reservations.reservation_not_confirmed')
    end
    redirect_to :back
    render_redirect_url_as_json if request.xhr?
  end

  def host_cancel
    if @recurring_booking.host_cancel
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

  def workflow_alerts_hash
    {
      enquirer: @recurring_booking.owner,
      lister: @recurring_booking.host,
      data: { recurring_booking: @recurring_booking.id, listing: @recurring_booking.listing.id, reservation: recurring_booking.reservations.first.id }
    }
  end
end
