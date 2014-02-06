class InstanceAdmin::Theme::DesignController < InstanceAdmin::Theme::BaseController

  def show
  end

  def update
    if @theme.update_attributes(params[:theme])
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to :action => :show
    else
      flash[:error] = @theme.errors.full_messages.to_sentence
      render :show
    end
  end
end
