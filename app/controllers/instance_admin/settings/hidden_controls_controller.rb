class InstanceAdmin::Settings::HiddenControlsController < InstanceAdmin::Settings::BaseController
  def update
    @instance.hidden_ui_controls = (params[:hidden_ui_controls] || {}).select { |_k, v| v == '1' }

    if @instance.save
      flash[:success] = t 'flash_messages.instance_admin.settings.hidden_controls.update'
      redirect_to instance_admin_settings_hidden_controls_path
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      render :show
    end
  end
end
