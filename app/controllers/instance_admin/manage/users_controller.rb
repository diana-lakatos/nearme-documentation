class InstanceAdmin::Manage::UsersController < InstanceAdmin::Manage::BaseController
  defaults resource_class: User, collection_name: 'users', instance_name: 'user', route_prefix: 'instance_admin'

  skip_before_filter :authorize_user!, only: [:restore_session]

  def index
  end

  def edit
    @user = User.with_deleted.find(params[:id])
    render :modal_edit, layout: false if request.xhr?
  end

  def update
    @user = User.find(params[:id])
    @user.assign_attributes(user_params)
    # We want the admin user to be able to make the user featured (or other changes) without regard
    # to how things stand with the user (might be missing a photo or a phone etc.)
    @user.save(validate: false)
    if request.xhr?
      render layout: false
    else
      flash[:success] = "#{@user.first_name} has been updated successfully"
      redirect_to instance_admin_manage_users_path
    end
  end

  def login_as
    if resource.admin?
      flash[:error] = t('flash_messages.instance_admin.manage.users.login_as.no_permissions')
      redirect_to(instance_admin_manage_users_path) && return
    end

    admin_user = current_user
    sign_out

    # Add special session parameters to flag we're an instance admin
    # logged in as the user.
    session[:instance_admin_as_user] = {
      user_id: resource.id,
      admin_user_id: admin_user.id,
      redirect_back_to: request.referer
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

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = t('flash_messages.instance_admin.manage.users.deleted')
    redirect_to edit_instance_admin_manage_user_path(@user)
  end

  def restore
    @user = User.with_deleted.find(params[:id])
    if User.exists?(email: @user.email)
      flash[:error] = t('flash_messages.instance_admin.manage.users.restore_email_taken')
    else
      @user.restore
      flash[:success] = t('flash_messages.instance_admin.manage.users.restored')
    end
    redirect_to edit_instance_admin_manage_user_path(@user)
  end

  protected

  def user_params
    params.require(:user).permit(secured_params.user_from_instance_admin)
  end

  def collection_search_fields
    %w(name email)
  end

  def collection
    if @users.blank?
      @user_search_form = InstanceAdmin::UserSearchForm.new
      @user_search_form.validate(params)
      users_scope = User.for_instance(PlatformContext.current.instance).order('created_at DESC').with_deleted
      @users = SearchService.new(users_scope).search(@user_search_form.to_search_params).paginate(page: params[:page], per_page: reports_per_page)
    end

    @users
  end
end
