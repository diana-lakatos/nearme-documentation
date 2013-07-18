class DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_company, :only => [:payments]
  before_filter :redirect_if_no_company, :only => [:payments]

  def show
    if current_user.reservations.visible.any?
      redirect_to bookings_dashboard_url
    elsif current_user.reservations.upcoming.any?
      redirect_to manage_guests_dashboard_url
    else
      redirect_to edit_user_registration_url
    end
  end

  def index
    if current_user.companies.blank?
      flash[:warning] = "Please add your company first"
      redirect_to new_space_wizard_url
    end
  end

  #routes
  def manage_guests
    @locations  = current_user.try(:companies).first.try(:locations)
    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
  end

  def locations
    @locations ||= current_user.companies.first.locations.all
  end

  def listings
    @listings = current_user.companies.first.listings.all
  end

  def bookings
    @your_reservations = current_user.reservations.visible.to_a.sort_by(&:date)
    unless @your_reservations.any?
      flash[:warning] = "You haven't made any bookings yet!"
      redirect_to search_path
    end
  end

  def payments
    # All paid ReservationCharges paginated
    @charges = @company.reservation_charges.paid.order('paid_at DESC')
    @charges = @charges.includes(:reservation => { :listing => :location })
    @charges = @charges.paginate(
      :page => params[:page],
      :per_page => 20
    )

    # Charges specifically from the last 7 days
    @last_week_charges = @company.reservation_charges.paid.last_x_days(6).
      order('created_at ASC')

    # Charge total summary by currency
    @all_time_totals = @company.reservation_charges.paid.total_by_currency
  end

  private

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company && @company.id
      flash[:warning] = "Please add your company first"
      redirect_to new_space_wizard_url
    end
  end

end
