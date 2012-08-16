class OrganizationsController < ApplicationController
  expose(:organization)

  def create
    if organization.save
      flash[:success] = "Successfully created organization"
      redirect_to redirect_path
    else
      flash.now[:error] = "There was an error saving your organization"
      render 'new'
    end
  end

  def redirect_path
    if params[:namespace] == 'user'
      edit_user_path(current_user)
    else
      new_location_path
    end
  end
end
