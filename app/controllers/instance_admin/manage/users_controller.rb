class InstanceAdmin::Manage::UsersController < InstanceAdmin::Manage::BaseController

  def index
    @user = User.new
    @instance_admin = InstanceAdmin.new
  end

  def create
    @user = User.new(params[:user])
    @user.skip_password = true
    if @user.save
      @user.set_platform_context(platform_context)
      InstanceAdmin.create(:user_id => @user.id, :instance_id => platform_context.instance.id)
      PostActionMailer.enqueue.created_by_instance_admin(platform_context, @user, current_user)
      flash[:success] = "User has been successfully created"
      redirect_to instance_admin_manage_users_path
    else
      render :index
    end
  end

end
