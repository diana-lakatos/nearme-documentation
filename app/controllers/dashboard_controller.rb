# TODO This whole thing should not be used anymore under new dashboard
class DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :force_scope_to_instance
  before_filter :find_company, :only => [:analytics, :transfers]
  before_filter :redirect_if_no_company, :only => [:analytics, :transfers]

  def show
    if current_user.orders.reservations.visible.any?
      redirect_to bookings_dashboard_url
    elsif current_user.orders.reservations.upcoming.any?
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
