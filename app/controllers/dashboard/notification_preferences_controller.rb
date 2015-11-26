class Dashboard::NotificationPreferencesController < Dashboard::BaseController

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.assign_attributes(notification_preferences_params)
    if @user.save
      redirect_to edit_dashboard_notification_preferences_path
    else
      render :edit
    end
  end

  def notification_preferences_params
    params.require(:user).permit(secured_params.notification_preferences)
  end
end

