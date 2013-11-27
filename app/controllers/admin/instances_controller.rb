class Admin::InstancesController < Admin::ResourceController

  def new
    @user = User.new
    new!
  end

  def create
    without_user = params[:user][:name].blank? && params[:user][:email].blank?
    unless without_user
      @user = User.new(params[:user])
      user_password = @user.generate_random_password!
    end

    @instance = Instance.new(params[:instance])
    @instance.valid?
    if (without_user || @user.valid?) && @instance.valid?
      @instance.save
      if !without_user && @user.save
        InstanceAdmin.create(user_id: @user.id, instance_id: @instance.id)
        PostActionMailer.enqueue.instance_created(platform_context, @instance, @user, user_password)
      end

      redirect_to admin_instance_path(@instance), notice: 'Instance was successfully created.'
    else
      render :new
    end
  end

end
