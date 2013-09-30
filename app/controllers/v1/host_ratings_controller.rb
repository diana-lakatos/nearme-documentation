class V1::HostRatingsController <  V1::BaseController
  before_filter :verify_authenticity_token
  before_filter :require_authentication
  before_filter :find_reservation

  def create
    @rating = HostRating.new(params[:host_rating])
    @rating.reservation = @reservation
    @rating.subject = @reservation.listing.location.creator
    @rating.author = current_user
    if @rating.save
      event_tracker.submitted_a_rating(current_user, {positive: @rating.positive?})
      render :json => {:success => true, :id => @rating.id}
    else
      render :json => { :errors => @rating.errors.full_messages }, :status => 422
    end
  end

  private
  def find_reservation
    @reservation = current_user.reservations.find(params[:reservation_id])
  end

end
