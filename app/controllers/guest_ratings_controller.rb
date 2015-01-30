# TODO: Delete after new rating system is implemented
class GuestRatingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_reservation

  def new
    @rating = GuestRating.new
    render :template => 'ratings/new'
  end

  def create
    @rating = GuestRating.new(rating_params)
    @rating.reservation = @reservation
    @rating.subject = @reservation.owner
    @rating.author = current_user
    if @rating.save
      event_tracker.submitted_a_rating(current_user, {positive: @rating.positive?})
      flash[:notice] = t('flash_messages.guest_rating.submitted_successfully')
      redirect_to root_path
      render_redirect_url_as_json if request.xhr?
    else
      render :template => 'ratings/new'
    end
  end

  private
  def find_reservation
    @reservation = current_user.listing_reservations.find(params[:reservation_id])
  end

  def rating_params
    params.require(:guest_rating).permit(secured_params.rating)
  end

end
