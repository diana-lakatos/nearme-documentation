class Admin::InstancesController < Admin::ResourceController
  before_filter lambda { PlatformContext.current = PlatformContext.new(Instance.find(params[:id])) }, :only => [:edit, :update, :destroy, :show]
  before_filter :normalize_required_fields, only: [:create, :update]
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
        @instance.instance_profile_types.create(name: 'User Instance Profile') if @instance.instance_profile_types.size.zero?
        @user.instance = @instance
        @user.save!
      end
    rescue
      flash.now[:error] = @user.errors.full_messages.to_sentence +
        @instance.errors.full_messages.to_sentence
      render :new and return
    end

    PlatformContext.current = PlatformContext.new(@instance)
    tp = @instance.transactable_types.create(name: params[:marketplace_type], pricing_options: { "free"=>"1", "hourly"=>"1", "daily"=>"1", "weekly"=>"1", "monthly"=>"1" },
                                             availability_options: { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => true } })
    if @instance.buyable?
      CustomAttributes::CustomAttribute::Creator.new(tp).create_buy_sell_attributes!
      Utils::SpreeDefaultsLoader.new(@instance).load!
    else
      CustomAttributes::CustomAttribute::Creator.new(tp, @instance.bookable_noun).create_listing_attributes!
      at = tp.availability_templates.build(name: "Working Week", description: "Mon - Fri, 9:00 AM - 5:00 PM")
      (1..5).each do |i|
        at.availability_rules.build(day: i, open_hour: 9, open_minute: 0,close_hour: 17, close_minute: 0)
      end
      at.save!
      @instance.location_types.create!(name: 'General')
    end

    InstanceAdmin.create(user_id: @user.id)
    PostActionMailer.enqueue.instance_created(@instance, @user, user_password)

    blog_instance = BlogInstance.new(name: @instance.name + ' Blog')
    blog_instance.owner = @instance
    blog_instance.save!

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

  def normalize_required_fields
    params[:instance][:user_required_fields] = params[:instance][:user_required_fields].split(',').map(&:strip).reject(&:blank?)
  end

end
