class CompaniesController < ApplicationController
  before_filter :authenticate_user!
  expose :company

  def create
    company.creator = current_user
    if company.save
      flash[:success] = "Successfully created company"
      redirect_to new_location_path
    else
      flash.now[:error] = "There was a problem saving your company. Please try again"
      render :new
    end
  end
end
