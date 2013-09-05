class GuestRatingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_reservation

  def new
    @rating = GuestRating.new
    render :template => 'ratings/new'
  end

  def create
    @rating = GuestRating.new(params[:guest_rating])
    @rating.reservation = @reservation
    @rating.subject = @reservation.owner
    @rating.author = current_user
    if @rating.save
      event_tracker.submitted_a_rating(current_user, {positive: @rating.positive?})
      flash[:notice] = 'Thanks, your rating was submitted successfully!'
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

end
