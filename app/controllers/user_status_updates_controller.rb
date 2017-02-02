# frozen_string_literal: true
class UserStatusUpdatesController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.user_status_updates.create(permitted_params)
    redirect_to request.referer
  end

  def update
    @user_status_update = UserStatusUpdate.find(params[:id])
    return render nothing: true unless @user_status_update.can_edit?(current_user)
    @user_status_update.update(permitted_params)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def destroy
    @user_status_update = UserStatusUpdate.find(params[:id])
    return render nothing: true unless @user_status_update.can_remove?(current_user) && @user_status_update.destroy
  end

  private

  def permitted_params
    params[:user_status_update].permit!
  end
end
