class InstanceAdmin::Manage::UsersController < InstanceAdmin::Manage::BaseController
  defaults :resource_class => User, :collection_name => 'users', :instance_name => 'user', :route_prefix => 'instance_admin'

  skip_before_filter :authorize_user!, :only => [:restore_session]

  def index
  end

  def login_as
    admin_user = current_user
    sign_out

    # Add special session parameters to flag we're an instance admin
    # logged in as the user.
    session[:instance_admin_as_user] = {
      :user_id => resource.id,
      :admin_user_id => admin_user.id,
      :redirect_back_to => request.referer
    }

    sign_in_resource(resource)
    redirect_to params[:return_to] || root_url
  end

  def restore_session
    if session[:instance_admin_as_user].present?
      client_user = current_user
      admin_user = User.find(session[:instance_admin_as_user][:admin_user_id])
      redirect_url = session[:instance_admin_as_user][:redirect_back_to] || instance_admin_users_url(client_user)
      sign_out # clears session
      sign_in_resource(admin_user)
      redirect_to redirect_url
    end
  end

  protected

  def collection_search_fields
    %w(name email)
  end

  def collection
    @users ||= UsersService.new(platform_context, params).get_users.paginate(:page => params[:page])
  end
end
