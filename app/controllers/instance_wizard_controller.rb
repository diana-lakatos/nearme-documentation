class InstanceWizardController < ActionController::Base
  protect_from_forgery
  layout 'platform_home'

  before_filter :check_whitelist, only: [:new, :create]
  before_filter :find_or_build_user, only: [:new, :create]

  def secured_params
    @secured_params ||= SecuredParams.new
  end

  def index
  end

  def new
    @instance = Instance.new
  end

  def create
    @instance = Instance.new(instance_params)

    unless instance_params[:domains_attributes] && instance_params[:domains_attributes]["0"][:name]
      flash.now[:error] = "You must create a domain, e.g. your-market.near-me.com"
      render :new and return
    end

    @instance.domains.first.use_as_default = true
    @instance.theme.support_email = @instance.theme.contact_email

    user_password = nil
    if @user.new_record?
      @user.name = user_params[:name]
      user_password = @user.generate_random_password!
    end

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

    @instance_creator.update_attribute(:created_instance, true)

    PlatformContext.current = PlatformContext.new(@instance)

    if params[:marketplace_type] == "Buy/Sell"
      @instance.product_types.create(name: @instance.bookable_noun)
      @instance.update_attribute :default_search_view, 'products'
    end

    tp = @instance.transactable_types.create(
      name: params[:marketplace_type],
      action_free_booking: "1",
      action_hourly_booking: "1",
      action_daily_booking: "1",
      action_weekly_booking: "1",
      action_monthly_booking: "1",
      availability_options: { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => true } })
    create_rating_systems(@instance)
    CustomAttributes::CustomAttribute::Creator.new(tp, bookable_noun: @instance.bookable_noun).create_listing_attributes!
    at = tp.availability_templates.build(name: "Working Week", description: "Mon - Fri, 9:00 AM - 5:00 PM")
    (1..5).each do |i|
      at.availability_rules.build(day: i, open_hour: 9, open_minute: 0,close_hour: 17, close_minute: 0)
    end
    at.save!
    Utils::FormComponentsCreator.new(tp).create!
    @instance.location_types.create!(name: 'General')

    Utils::DefaultAlertsCreator.new.create_all_workflows!
    InstanceAdmin.create(user_id: @user.id)

    blog_instance = BlogInstance.new(name: @instance.name + ' Blog')
    blog_instance.owner = @instance
    blog_instance.save!

    WorkflowStepJob.perform(WorkflowStep::InstanceWorkflow::Created, @instance.id, @user.id, user_password || '[using existing account password]')

    redirect_to @instance.domains.first.url
  end

  private

  def check_whitelist
    @instance_creator = InstanceCreator.find_by_email(params[:instance_creator] && params[:instance_creator][:email])
    if @instance_creator && @instance_creator.created_instance?
      flash[:error] = 'Sorry, that email has already been used. Please <a href="/contact">contact us</a>.'.html_safe
      redirect_to action: :index and return
    elsif !@instance_creator
      flash[:error] = 'Sorry, that email was not pre-approved. Please <a href="/contact">contact us</a>.'.html_safe
      redirect_to action: :index and return
    end
  end

  def find_or_build_user
    @user = User.find_by_email(@instance_creator.email) || User.new(email: @instance_creator.email)
  end

  def create_rating_systems(instance)
    instance.transactable_types.each do |transactable_type|
      [instance.lessor, instance.lessee, instance.bookable_noun].each do |subject|
        rating_system = instance.rating_systems.create(subject: subject, transactable_type_id: transactable_type.id)
        RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.create(value: value, instance: instance) }
      end
    end
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end

  def user_params
    params.require(:user).permit(secured_params.user)
  end

end
