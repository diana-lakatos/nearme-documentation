class Admin::UsersController < Admin::ResourceController
  skip_before_filter :require_administrator, :only => [:restore_session]

  def login_as
    admin_user = current_user
    sign_out

    # Add special session parameters to flag we're an admin
    # logged in as the user.
    session[:admin_as_user] = {
      :user_id => resource.id,
      :admin_user_id => admin_user.id,
      :redirect_back_to => request.referer
    }

    sign_in(resource)
    redirect_to params[:return_to] || root_url
  end

  def restore_session
    if session[:admin_as_user].present?
      client_user = current_user
      admin_user = User.find(session[:admin_as_user][:admin_user_id])
      redirect_url = session[:admin_as_user][:redirect_back_to] || admin_user_url(client_user)
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

