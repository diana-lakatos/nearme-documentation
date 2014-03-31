class InstanceAdmin::ManageBlog::BaseController < InstanceAdmin::ResourceController
  CONTROLLERS = { 'posts' => { default_action: 'index' },
                  'settings'   => { default_action: 'edit' }}

  before_filter :find_blog_instance

  def index
    redirect_to instance_admin_manage_blog_posts_path
  end

  private

  def find_blog_instance
    @blog_instance = platform_context.instance.blog_instance
  end
end
