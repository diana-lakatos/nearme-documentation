class InstanceAdmin::InventoriesController < InstanceAdmin::ResourceController
  defaults :resource_class => User, :collection_name => 'users', :instance_name => 'user', :route_prefix => 'instance_admin'

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

    sign_in(resource)
    redirect_to params[:return_to] || root_url
  end

  def restore_session
    if session[:instance_admin_as_user].present?
      client_user = current_user
      admin_user = User.find(session[:instance_admin_as_user][:admin_user_id])
      redirect_url = session[:instance_admin_as_user][:redirect_back_to] || instance_admin_inventory_url(client_user)
      sign_out # clears session
      sign_in(admin_user)
      redirect_to redirect_url
    end
  end

  protected

  def collection_search_fields
    %w(name email)
  end

end
