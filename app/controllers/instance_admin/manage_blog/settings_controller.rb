class InstanceAdmin::ManageBlog::SettingsController < InstanceAdmin::ManageBlog::BaseController

  def edit
  end

  def update
    if @blog_instance.update_attributes(instance_params)
      flash[:success] = t('flash_messages.blog_admin.blog_instance.blog_instance_updated')
      redirect_to edit_instance_admin_manage_blog_settings_path
    else
      render 'edit'
    end
  end

  private

  def instance_params
    params.require(:blog_instance).permit(secured_params.blog_instance)
  end
end
