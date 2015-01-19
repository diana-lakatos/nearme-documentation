# TODO This whole thing should not be used anymore under new dashboard
class DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :force_scope_to_instance
  before_filter :find_company, :only => [:analytics, :transfers]
  before_filter :redirect_if_no_company, :only => [:analytics, :transfers]

  def show
    if current_user.reservations.visible.any?
      redirect_to bookings_dashboard_url
    elsif current_user.reservations.upcoming.any?
      redirect_to manage_guests_dashboard_url
    else
      redirect_to edit_user_registration_url
    end
  end

  def listings
    @listings = current_user.companies.first.listings.all
  end

  def transfers
    # All transferred PaymentTransfers paginated
    @payment_transfers = @company.payment_transfers.transferred.order('transferred_at DESC')
    @payment_transfers = @payment_transfers.paginate(page: params[:page], per_page: 20)

    # PaymentTransfers specifically from the last 7 days
    @last_week_payment_transfers = @company.
                                    payment_transfers.
                                    transferred.
                                    last_x_days(6).
                                    order('created_at ASC')

    @chart = ChartDecorator.decorate(@last_week_payment_transfers)
  end

  # TODO: Delete after new rating system implemented
  def guest_rating
    @reservation = current_user.listing_reservations.find(params[:id])
    existing_guest_rating = GuestRating.where(reservation_id: @reservation.id,
                                              author_id: current_user.id)

    if params[:track_email_event]
      event_tracker.track_event_within_email(current_user, request)
      params[:track_email_event] = nil
    end

    if existing_guest_rating.blank?
      manage_guests
      render :manage_guests
    else
      flash[:notice] = t('flash_messages.guest_rating.already_exists')
      redirect_to root_path
    end
  end

  private

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    if @company.nil?
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to new_space_wizard_path
    elsif !@company.valid?
      flash[:warning] = t('flash_messages.dashboard.company_not_valid')
      redirect_to edit_dashboard_company_path(@company)
    end
  end
end
