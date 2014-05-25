class Admin::InstancesController < Admin::ResourceController
  before_filter lambda { PlatformContext.current = PlatformContext.new(Instance.find(params[:id])) }, :only => [:edit, :update, :destroy, :show]

  def new
    @user = User.new
    new!
  end

  def create
    @instance = Instance.new(params[:instance])
    @user = User.new(params[:user])
    user_password = @user.generate_random_password!

    begin
      Instance.transaction do
        @instance.save!
        @user.instance = @instance
        @user.save!
      end
    rescue
      flash.now[:error] = @user.errors.full_messages.to_sentence +
                          @instance.errors.full_messages.to_sentence
      render :new and return
    end

    PlatformContext.current = PlatformContext.new(@instance)
    InstanceAdmin.create(user_id: @user.id)
    PostActionMailer.enqueue.instance_created(@instance, @user, user_password)

    blog_instance = BlogInstance.new(name: @instance.name + ' Blog')
    blog_instance.owner = @instance
    blog_instance.save!

    # Create a default transactable type with associated attributes
    t = @instance.transactable_types.create(name: 'Listing')
    Utils::TransactableTypeAttributesCreator.new(t).create_listing_attributes!

    redirect_to admin_instance_path(@instance), notice: 'Instance was successfully created.'
  end
end
