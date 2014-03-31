class InstanceAdmin::ManageBlog::SettingsController < InstanceAdmin::ManageBlog::BaseController

  def edit
  end

  def update
    if @blog_instance.update_attributes(params[:blog_instance])
      flash[:success] = t('flash_messages.blog_admin.blog_instance.blog_instance_updated')
      redirect_to edit_instance_admin_manage_blog_settings_path
    else
      render 'edit'
    end
  end
end
