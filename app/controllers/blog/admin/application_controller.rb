class Blog::Admin::ApplicationController < Blog::ApplicationController

  before_filter :authenticate_user!
  before_filter :authorize_user!

  layout 'blog_admin'

  private

  def authorize_user!
    @authorizer ||= BlogAdminAuthorizer.new(current_user, platform_context)
    if not @authorizer.authorized?
      flash[:warning] = t('flash_messages.authorizations.not_authorized')
      redirect_to root_path
    end
  end

end
