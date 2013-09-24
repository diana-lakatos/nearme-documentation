class DashboardController < ApplicationController
  before_filter :authenticate_user!
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

  def manage_guests
    @locations  = current_user.try(:companies).first.try(:locations)
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
  end

  def listings
    @listings = current_user.companies.first.listings.all
  end

  def analytics
    @analytics_mode = params[:analytics_mode] || 'revenue'

    case @analytics_mode
    when 'revenue'
      prepare_data_for_analytics_revenue
    when 'bookings'
      prepare_data_for_analytics_bookings
    when 'location_views'
      prepare_data_for_analytics_location_views
    end 
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

    @weekly_chart = WeeklyChartDecorator.decorate(@last_week_payment_transfers)
  end

  private

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company && @company.id
      flash[:warning] = t('dashboard.add_your_company')
      redirect_to new_space_wizard_url
    end
  end

  def prepare_data_for_analytics_revenue
    # All paid ReservationCharges paginated
    @reservation_charges = @company.reservation_charges.paid.order('paid_at DESC')
    @reservation_charges = @reservation_charges.includes(:reservation => { :listing => :location })
    @reservation_charges = @reservation_charges.paginate(
      :page => params[:page],
      :per_page => 20
    )

    # Charges specifically from the last 7 days
    @last_week_reservation_charges = @company.reservation_charges.paid.last_x_days(6).
      order('created_at ASC')

    # Charge total summary by currency
    @all_time_totals = @company.reservation_charges.paid.total_by_currency

    @weekly_chart = WeeklyChartDecorator.decorate(@last_week_reservation_charges)
  end

  def prepare_data_for_analytics_bookings
    # All company reservations paginated
    @reservations = @company.reservations.order('created_at DESC')
    @reservations = @reservations.paginate(
      :page => params[:page],
      :per_page => 20
    )

    @last_week_reservations = @company.reservations.last_x_days(6).order('created_at ASC')
  end


  def prepare_data_for_analytics_location_views
    @visits = @company.locations_impressions.select('COUNT(impressions.*) AS impressions_count, DATE(impressions.created_at) AS impression_date').group('impression_date')

    # Visits form last 30 days
    @last_month_visits = @visits.where('DATE(impressions.created_at) >= ?', Date.current - 30.days).order('impression_date ASC')

    # All company location visits paginated
    @visits = @visits.order('DATE(impressions.created_at) DESC').paginate(
      :page => params[:page],
      :per_page => 30,
      :total_entries => @company.locations_impressions.group('DATE(impressions.created_at)').count.size 
    )
  end

end
