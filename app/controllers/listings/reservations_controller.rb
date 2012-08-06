module Listings
  class ReservationsController < ::ReservationsController
    before_filter :find_listing
    before_filter :require_creator, :except => [:new, :create]
    before_filter :find_date, :only => [:new, :create]
    before_filter :ensure_date_valid, :only => [:new, :create]
    before_filter :ensure_desk_available, :only => [:new, :create]

    def index
    end

    def new
      session[:user_return_to] = current_user ? nil : request.fullpath
      @reservation = @reservations.build(:date => params[:date])
      respond_to do |wants|
        wants.js { render :layout => false }
        wants.html { render }
      end
    end

    def create
      session[:user_return_to] = nil
      @reservation = @reservations.build(params[:reservation].merge(:user => current_user))
      if @reservation.save
        flash[:notice] = "Reservation Successful."
        begin
          redirect_to request.xhr? ? :back : @listing
        rescue
          redirect_to @listing
        end
      else
        render :new
      end
    end

    protected

    def ensure_date_valid
      if @date < Date.today
        flash[:notice] = "Who do you think you are, Marty McFly? You can't book a desk in the past!"
        redirect_to @listing and return
      end
    end

    def ensure_desk_available
      unless @listing.desks_available?(@date)
        flash[:notice] = "There are no more desks left for that date. Sorry."
        redirect_to @listing and return
      end
    end

    def require_creator
      unless @listing.created_by?(current_user)
        flash[:error] = "You didn't create this listing, so you can't do stuff to it."
        redirect_to @listing
      end
    end

    def find_date
      @date = Date.parse(params[:date] || params[:reservation][:date])
    rescue
      @date = Date.today
    end

    def find_listing
      @listing ||= Listing.find(params[:listing_id])
    end

    def fetch_reservations
      @reservations = find_listing.reservations
    end

    def allowed_events
      events = [:owner_cancel]
      events += [:confirm, :reject] if find_listing.confirm_reservations?
      events
    end
  end
end
