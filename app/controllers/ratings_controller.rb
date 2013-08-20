class RatingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_reservation
  before_filter :find_subject

  def new
    @rating = rating_class.new
  end

  def create
    @rating = rating_class.new(params[rating_class.to_s.underscore])
    @rating.reservation = @reservation
    @rating.subject = @subject
    @rating.author = current_user
    if @rating.save
      flash[:notice] = 'Rating was successfully stored. Thank you for sharing!'
      redirect_to root_path
    else
      render :new
    end
  end

  private
  def find_reservation
    scope = if kind == 'guest'
              current_user.listing_reservations
            elsif kind == 'host'
              current_user.reservations
            end
    @reservation = scope.find(params[:reservation_id])
  end

  def find_subject
    @subject = if kind == 'guest'
                 @reservation.owner
               elsif kind == 'host'
                 @reservation.listing.location.creator
               end
  end

  def rating_class
    @rating_class ||= "#{kind.capitalize}Rating".constantize
  end

  def kind
    @kind ||= request.path.match(/\/(\w+)_ratings/)[1]
  end

end
