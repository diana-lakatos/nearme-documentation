class InstanceAdmin::Settings::HiddenControlsController < InstanceAdmin::Settings::BaseController

  def update
    @instance.hidden_ui_controls = (params[:hidden_ui_controls] || {}).select{|k,v|  v == '1'}
    unless @instance.save
      flash[:error] = @instance.errors.full_messages.to_sentence
    end
    render :show
  end

end
