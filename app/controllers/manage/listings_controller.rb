class Manage::ListingsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_listing, :except => [:index]
  before_filter :find_location, :only => [:index]

  def index
  end

  private

  def find_location
    @location = current_user.locations.find(params[:location_id])
  end

end
