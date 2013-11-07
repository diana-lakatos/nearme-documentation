class InstanceAdmin::Users::InstanceAdminsController < InstanceAdmin::BaseController

  def index
    redirect_to instance_admin_users_path
  end

  def create
    @user = User.where(:email => params[:email]).first
    if @user
      InstanceAdmin.find_or_create_by_user_id_and_instance_id(@user.id, platform_context.instance.id)
      flash[:success] = "User with email #{@user.email} has been successfully added as admin"
      redirect_to instance_admin_users_path
    else
      flash[:error] = "Unfortunately we could not find user with email \"#{params[:email]}\""
      render "instance_admin/users/index" 
    end
  end

  def update
    @instance_admin = platform_context.instance.instance_admins.find(params[:id])
    unless @instance_admin.instance_owner
      @instance_admin.update_attribute(:instance_admin_role_id, InstanceAdminRole.belongs_to_instance(platform_context.instance.id).find(params[:instance_admin_role_id]).id)
    end
    render :nothing => true
  end

  def destroy
    @instance_admin = platform_context.instance.instance_admins.find(params[:id])
    if @instance_admin.instance_owner
      flash[:error] = 'Instance owner cannot be deleted'
    else
      @instance_admin.destroy
      flash[:deleted] = "#{@instance_admin.name} is no longer instance admin"
    end
    redirect_to instance_admin_users_path
  end

  private 

  def permitting_controller_class
    # currently we assume that if user has access to UsersController, he is permitted to do any action. 
    # Later, if we end up having more granular permissions, we will be able to just remove this
    InstanceAdmin::UsersController
  end

end
