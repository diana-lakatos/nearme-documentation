class Admin::InstancesController < Admin::ResourceController
  before_filter lambda { PlatformContext.current = PlatformContext.new(Instance.find(params[:id])) }, :only => [:edit, :update, :destroy, :show]
  skip_before_filter :check_if_locked, only: [:lock, :edit]

  def new
    @user = User.new
    new!
  end

  def create
    @instance = Instance.new(instance_params)
    @user = User.new(user_params)
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
    tp = @instance.transactable_types.create(name: 'Listing', pricing_options: { "free"=>"1", "hourly"=>"1", "daily"=>"1", "weekly"=>"1", "monthly"=>"1" },
                                             availability_options: { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => true } })
    Utils::TransactableTypeAttributesCreator.new(tp).create_listing_attributes!
    at = tp.availability_templates.build(name: "Working Week", description: "Mon - Fri, 9:00 AM - 5:00 PM")
    (1..5).each do |i|
      at.availability_rules.build(day: i, open_hour: 9, open_minute: 0,close_hour: 17, close_minute: 0)
    end
    at.save!
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

  private

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end

  def user_params
    params.require(:user).permit(secured_params.user)
  end

  def lock
    @instance = Instance.find(params[:id])
    if @instance.update_attributes(params[:instance])
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      redirect_to action: :edit
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      redirect_to action: :edit
    end
  end
end
