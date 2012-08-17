class OrganizationsController < ApplicationController
  expose(:organization)

  def create
    if organization.save
      flash[:success] = "Successfully created organization"
      redirect_to dashboard_path
    else
      flash.now[:error] = "There was an error saving your organization"
      render 'new'
    end
  end
end
