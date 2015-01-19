class InstanceAdmin::Settings::DashboardController < InstanceAdmin::Settings::BaseController

  def update
    @instance.hidden_dashboard_menu_items = (params[:hidden_dashboard_menu_items] || {}).select{|k,v|  v == '1'}
    unless @instance.save
      flash[:error] = @instance.errors.full_messages.to_sentence
    end
    render :show
  end

end
