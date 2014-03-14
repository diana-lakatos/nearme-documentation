class InstanceAdmin::Manage::Users::InstanceAdminsController < InstanceAdmin::Manage::BaseController

  def index
    redirect_to instance_admin_manage_users_path
  end

  def create
    @user = User.where(:email => params[:email]).first
    if @user
      InstanceAdmin.create(:user_id => @user.id) unless InstanceAdmin.where(:user_id => @user.id).first.present?
      flash[:success] = "User with email #{@user.email} has been successfully added as admin"
      redirect_to instance_admin_manage_users_path
    else
      flash[:error] = "Unfortunately we could not find user with email \"#{params[:email]}\""
      render "instance_admin/manage/users/index"
    end
  end

  def update
    @instance_admin = InstanceAdmin.find(params[:id])
    unless @instance_admin.instance_owner
      @instance_admin.update_attribute(:instance_admin_role_id, InstanceAdminRole.find(params[:instance_admin_role_id]).id)
    end
    render :nothing => true
  end

  def destroy
    @instance_admin = InstanceAdmin.find(params[:id])
    if @instance_admin.instance_owner
      flash[:error] = 'Instance owner cannot be deleted'
    else
      @instance_admin.destroy
      flash[:deleted] = "#{@instance_admin.name} is no longer instance admin"
    end
    redirect_to instance_admin_manage_users_path
  end

  private

  def permitting_controller_class
    'manage'
  end
end
