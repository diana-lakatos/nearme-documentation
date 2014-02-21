class Admin::InstancesController < Admin::ResourceController
  before_filter lambda { PlatformContext.current = PlatformContext.new(Instance.find(params[:id])) }, :only => [:edit, :update, :destroy, :show]

  def new
    @user = User.new
    new!
  end

  def create
    without_user = params[:user].blank? || params[:user][:name].blank? && params[:user][:email].blank?
    unless without_user
      @user = User.new(params[:user])
      user_password = @user.generate_random_password!
    end

    @instance = Instance.new(params[:instance])
    if (without_user || @user.valid?) && @instance.valid?
      @instance.save
      PlatformContext.current = PlatformContext.new(@instance)
      if !without_user && @user.save
        InstanceAdmin.create(user_id: @user.id)
        PostActionMailer.enqueue.instance_created(@instance, @user, user_password)
      end

      blog_instance = BlogInstance.new(name: @instance.name + ' Blog')
      blog_instance.owner = @instance
      blog_instance.save!

      redirect_to admin_instance_path(@instance), notice: 'Instance was successfully created.'
    else
      render :new
    end
  end

end
