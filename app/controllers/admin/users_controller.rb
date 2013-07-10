class Admin::UsersController < Admin::ResourceController
  skip_before_filter :require_administrator, :only => [:restore_session]

  def login_as
    admin_user = current_user
    sign_out

    # Add special session parameters to flag we're an admin
    # logged in as the user.
    session[:admin_as_user] = {
      :user_id => resource.id,
      :admin_user_id => admin_user.id
    }

    sign_in(resource)
    redirect_to root_url
  end

  def restore_session
    if session[:admin_as_user].present?
      client_user = current_user
      admin_user = User.find(session[:admin_as_user][:admin_user_id])
      sign_out # clears session
      sign_in(admin_user)
      redirect_to admin_user_url(client_user)
    end
  end

  private

  def collection
    search = params[:search]

    if search.present?
      escaped_search = ActiveRecord::Base.connection.quote_string(search)
      end_of_association_chain.where("name ILIKE '#{escaped_search}%' OR email ILIKE '#{escaped_search}%'").paginate(:page => params[:page])
    else
      super
    end
  end
end

