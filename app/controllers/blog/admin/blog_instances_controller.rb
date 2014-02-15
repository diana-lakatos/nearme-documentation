class Blog::Admin::BlogInstancesController < Blog::Admin::ApplicationController

  def edit
  end

  def update
    if @blog_instance.update_attributes(params[:blog_instance])
      flash[:success] = t('flash_messages.blog_admin.blog_instance.blog_instance_updated')
      redirect_to blog_admin_blog_posts_path
    else
      render 'edit'
    end
  end

end
