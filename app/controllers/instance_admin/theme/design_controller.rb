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

  def convert_to_new_ui
    unless current_instance.new_ui?
      if NewUiConverter.new(current_instance.id).convert_to_new_ui
        flash[:success] = "Sucessfully switched to new UI for dashboard"
      else
        flash[:notice] = "Unable to switch to new UI for dashboard"
      end
      redirect_to action: :show
    end
  end

  def revert_to_old_ui
    if current_instance.new_ui?
      if NewUiConverter.new(current_instance.id).revert_to_old_ui
        flash[:success] = "Sucessfully switched to old UI for dashboard"
      else
        flash[:notice] = "Unable to switch to new old for dashboard"
      end
    end
    redirect_to action: :show
  end

end

