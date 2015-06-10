class UserStatusUpdatesController < ApplicationController
  def create
    current_user.user_status_updates.create(permitted_params)
    redirect_to request.referer
  end

  private

  def permitted_params
    params[:user_status_update].permit!
  end
end
