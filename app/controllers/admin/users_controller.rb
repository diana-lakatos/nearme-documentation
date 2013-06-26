class Admin::UsersController < Admin::ResourceController
  def login_as
    admin_user = current_user
    sign_out

    # Add special session parameters for authentication strategy.
    session[:admin_as_user] = {
      :user_id => resource.id,
      :admin_user_id => admin_user.id
    }

    redirect_to root_url
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

