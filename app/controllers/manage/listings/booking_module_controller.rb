class Manage::Listings::BookingModuleController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing

  def update
    @listing.assign_attributes(listing_params)

    if @listing.save
      flash[:success] = t('flash_messages.manage.listings.listing_updated')
      redirect_to :back
    else
      flash[:error] = @listing.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  private

  def find_listing
    @listing = current_user.listings.find(params[:listing_id])
  end

  def listing_params
    params.require(:listing).permit(secured_params.transactable(@transactable_type))
  end
end
