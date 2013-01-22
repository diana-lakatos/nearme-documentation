class Manage::LocationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_location, :except => [:index]
  before_filter :find_company

  def index
  end

  def edit
  end

  def destroy
    if @location.destroy
      flash[:context_success] = "You've deleted #{@location.name}"
    else
      flash[:context_failure] = "We couldn't delete #{@location.name}"
    end
    redirect_to manage_company_locations_path @location.company
  end

  def update
    @location.attributes = params[:location]
    @location.address_components_hash = params[:address_components] || {}
    @location.build_address_components_if_necessary

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
