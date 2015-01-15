class Dashboard::GuestsController < Dashboard::BaseController
  def index
    if current_user.companies.any?
      @locations  = current_user.companies.first.locations
    else
      @locations = []
    end

    @guest_list = Controller::GuestList.new(current_user).filter(params[:state])
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end
end
