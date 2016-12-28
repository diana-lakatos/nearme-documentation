class GlobalAdmin::PlatformAdminsController < GlobalAdmin::ResourceController

  def create
    if user = User.find_by_email(params[:platform_admin][:email])
      if user.admin?
        flash[:error] = "#{params[:platform_admin][:email]} is already a platform admin."
      else
        user.update_column(:admin, true)
        flash[:success] = "#{params[:platform_admin][:email]} is now a platform admin."
      end
    else
      flash[:error] = "Could not find user with email #{params[:platform_admin][:email]}"
    end
    render :index
  end

  def destroy
    User.find(params[:id]).update_column(:admin, false)
    render :index
  end

  protected

  def collection
    @platform_admins ||= UsersService.new(nil, params).get_users.admin.paginate(:page => params[:page])
  end

  def platform_admin_params
    params.require(:platform_admin).permit(secured_params.user)
  end
end
