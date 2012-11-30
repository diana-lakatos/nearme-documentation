class Manage::LocationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_location, :except => [:index]
  before_filter :find_company

  def index
  end

  def edit
  end

  def update
    @location.attributes = params[:location]

    if @location.save
      flash[:context_success] = "Great, your Space has been updated!"
      redirect_to [:edit, :manage, @location]
    else
      render :edit
    end
  end

  private

  def find_location
    @location = current_user.locations.find(params[:id])
  end

  def find_company
    @company = if @location
      @location.company
    else
      current_user.companies.find(params[:company_id])
    end
  end
end
