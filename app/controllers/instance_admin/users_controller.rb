class InstanceAdmin::UsersController < InstanceAdmin::BaseController

  def index
    @user = User.new
    @instance_admin = InstanceAdmin.new
  end

  def create
    @user = User.new(params[:user])
    @user.skip_password = true
    if @user.save
      InstanceAdmin.create(:user_id => @user.id, :instance_id => platform_context.instance.id)
      PostActionMailer.enqueue.created_by_instance_admin(platform_context, @user, current_user)
      flash[:success] = "User has been successfully created"
      redirect_to instance_admin_users_path
    else
      render :index
    end
  end

end
