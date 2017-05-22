# frozen_string_literal: true
class Dashboard::NotificationPreferencesController < Dashboard::BaseController
  skip_before_action :redirect_unverified_user, only: :unsubscribe
  skip_before_action :authenticate_user!, only: :unsubscribe

  def edit
    @user = current_user
    @notification_preference = @user.notification_preference || @user.build_notification_preference
  end

  def update
    @user = current_user
    @user.assign_attributes(notification_preferences_params)

    if @user.save(validate: false)
      redirect_to edit_dashboard_notification_preferences_path, flash: { success: t('flash_messages.dashboard.notification_preferences.updated') }
    else
      render :edit
    end
  end

  def unsubscribe
    UnsubscribeEmailsService.new.unsubscribe params[:token]

    flash[:success] = t('flash_messages.dashboard.notification_preferences.updated')
    redirect_to root_path
  end

  def notification_preferences_params
    params.require(:user).permit(secured_params.notification_preferences)
  end
end
