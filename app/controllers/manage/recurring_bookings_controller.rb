class Manage::RecurringBookingsController  < Manage::BaseController

  def show
    if current_user.companies.any?
      @locations  = current_user.companies.first.locations
    else
      @locations = []
    end
    @recurring_booking = current_user.listing_recurring_bookings.find(params[:id]).decorate
    @guest_list = Controller::GuestList.new(current_user, @recurring_booking).filter(params[:state])
  end

end

