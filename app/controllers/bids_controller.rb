class BidsController < ApplicationController
  before_filter :find_offer
  before_filter :require_login_for_reservation
  before_filter :find_current_country, :only => [:new]

  def new
    @user = current_user
    @bid = @user.bids.new(offer: @offer, reservation_type: @offer.offer_type.reservation_type)
  end

  def create
    @user = current_user
    @user.assign_attributes(user_params) if params[:user]
    @bid = @offer.bids.new(reservation_type: @offer.offer_type.reservation_type, user: @user, offer_creator: @offer.creator)
    @bid.assign_attributes(bid_params)
    if @bid.valid? && @user.valid? && @bid.save && @user.save
      redirect_to @offer, notice: "Sucess"
    else
      render :new
    end
  end

  private

  def find_current_country
    if current_ip && current_ip != '127.0.0.1'
      @country = Geocoder.search(current_ip).first.try(:country)
    end
    @country ||= 'United States'
  rescue
    @country ||= 'United States'
  end

  def require_login_for_reservation
    unless user_signed_in?
      redirect_to new_user_session_path(return_to: new_offer_bid_path(@offer))
    end
  end

  def find_offer
    @offer = Offer.find(params[:offer_id])
  end

  def user_params
    params.require(:user).permit(secured_params.user(offer_type: @offer.offer_type.reservation_type))
  end

  def bid_params
    params.require(:bid).permit(secured_params.bid(@offer.offer_type.reservation_type))
  end
end
