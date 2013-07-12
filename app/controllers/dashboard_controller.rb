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
  end

  def payments
    @charges = @company.charges.successful.order('created_at DESC').paginate(:page => params[:page], :per_page => 20).includes(:reference => { :listing => :location })
    @last_week_charges = @company.charges.successful.order('created_at ASC').last_x_days(7)
    @all_time_totals = @company.charges.all_time_totals
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
