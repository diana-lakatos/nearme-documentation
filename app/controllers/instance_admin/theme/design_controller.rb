class InstanceAdmin::Theme::DesignController < InstanceAdmin::Theme::BaseController

  before_filter :find_image, :only => [:edit_image, :upload_image, :destroy_image, :update_image]

  def show
    @theme.theme_font || @theme.build_theme_font
  end

  def update
    if @theme.update_attributes(theme_params)
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to :action => :show
    else
      flash[:error] = @theme.errors.full_messages.to_sentence
      render :show
    end
  end

  def delete_font
    @theme.theme_font.destroy

    redirect_to :action => :show
  end

end

