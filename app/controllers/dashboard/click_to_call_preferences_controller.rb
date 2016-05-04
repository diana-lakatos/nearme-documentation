class Dashboard::ClickToCallPreferencesController < Dashboard::BaseController

  def edit
    @user = current_user
    if params[:phone] && params[:country_name]
      @user.mobile_number = params[:phone]
      @user.country_name = params[:country_name]
    end
  end

  def update
    @user = current_user
    @user.assign_attributes(click_to_call_preferences_params)
    if @user.save
      if request.xhr?
        head :ok
      else
        flash[:success] = t('flash_messages.dashboard.click_to_call_preferences.updated')
        redirect_to edit_dashboard_click_to_call_preferences_path
      end
    else
      if request.xhr?
        render :json, @user.errors, status: :unprocessable_entity
      else
        render :edit
      end
    end
  end

  def click_to_call_preferences_params
    params.require(:user).permit(secured_params.click_to_call_preferences)
  end
end

