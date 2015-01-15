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


  def rating
    @reservation = current_user.listing_reservations.find(params[:id])
    existing_guest_rating = GuestRating.where(reservation_id: @reservation.id,
                                              author_id: current_user.id)

    if params[:track_email_event]
      event_tracker.track_event_within_email(current_user, request)
      params[:track_email_event] = nil
    end

    if existing_guest_rating.blank?
      index
      render :index
    else
      flash[:notice] = t('flash_messages.guest_rating.already_exists')
      redirect_to index
    end
  end
end
