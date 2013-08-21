class GuestRatingsController < ApplicationController
  prepend_view_path 'app/views/ratings'
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
      flash[:notice] = 'Rating was successfully stored. Thank you for sharing!'
      redirect_to root_path
    else
      render :template => 'ratings/new'
    end
  end

  private
  def find_reservation
    @reservation = current_user.listing_reservations.find(params[:reservation_id])
  end

end
