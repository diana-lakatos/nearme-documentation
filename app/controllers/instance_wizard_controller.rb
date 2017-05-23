# frozen_string_literal: true
class InstanceWizardController < ActionController::Base
  protect_from_forgery
  layout 'instance_wizard'

  before_action :check_whitelist, only: [:new, :create]
  before_action :find_or_build_user, only: [:new, :create]

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

    unless @instance.domains.first.present?
      flash.now[:error] = 'You must create a domain, e.g. your-market.near-me.com'
      render(:new) && return
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
        @instance.build_availability_templates
        @instance.save!
        @instance.domains.first.update_column(:state, 'elb_secured')
        @instance.domains.first.update_column(:secured, true)
        @user.save!
        @user.update_column(:instance_id, @instance.id)
        @instance.theme.update_column(:instance_id, @instance.id)
      end
    rescue
      flash.now[:error] = @user.errors.full_messages.to_sentence +
                          @instance.errors.full_messages.to_sentence
      render(:new) && return
    end

    @instance_creator.update_attribute(:created_instance, true)
    @instance.set_context!

    Utils::FormComponentsCreator.new(@instance).create!

    ipt = @instance.instance_profile_types.create!(name: 'Default', profile_type: InstanceProfileType::DEFAULT)
    Utils::FormComponentsCreator.new(ipt).create!

    # We remove the profile created on before_create as it's attached to the wrong instance
    @user.default_profile.destroy
    @user.build_default_profile(instance_profile_type: ipt)
    @user.save!

    User.admin.find_each do |user|
      if user.default_profile.blank?
        user.create_default_profile!(
          instance_profile_type: ipt,
          skip_custom_attribute_validation: true
        )
      end
    end

    ipt = @instance.instance_profile_types.create!(name: 'Seller', profile_type: InstanceProfileType::SELLER)
    Utils::FormComponentsCreator.new(ipt).create!
    ipt = @instance.instance_profile_types.create!(name: 'Buyer', profile_type: InstanceProfileType::BUYER)
    Utils::FormComponentsCreator.new(ipt).create!
    tp = @instance.transactable_types.new(
      name: @instance.bookable_noun
    )
    tp.action_types << TransactableType::TimeBasedBooking.new(
      confirm_reservations: true,
      pricings_attributes: [
        {
          unit: 'hour',
          number_of_units: 1,
          allow_free_booking: true
        },
        {
          unit: 'day',
          number_of_units: 1,
          allow_free_booking: true
        },
        {
          unit: 'day',
          number_of_units: 7,
          allow_free_booking: true
        },
        {
          unit: 'day',
          number_of_units: 30,
          allow_free_booking: true
        }
      ]
    )
    tp.save!

    tp.create_rating_systems
    Utils::FormComponentsCreator.new(tp).create!

    @instance.location_types.create!(name: 'General')

    Utils::DefaultAlertsCreator.new.create_all_workflows!
    InstanceAdmin.create(user_id: @user.id)

    blog_instance = BlogInstance.new(name: @instance.name + ' Blog')
    blog_instance.owner = @instance
    blog_instance.save!

    @instance.locales.create! code: @instance.primary_locale, primary: true

    WorkflowStepJob.perform(WorkflowStep::InstanceWorkflow::Created, @instance.id, @user.id, user_password || '[using existing account password]', as: current_user)
    FormComponentToFormConfiguration.new(@instance).go!

    redirect_to @instance.domains.first.url
  end

  private

  def check_whitelist
    @instance_creator = InstanceCreator.find_by(email: params[:instance_creator] && params[:instance_creator][:email])
    if @instance_creator && @instance_creator.created_instance?
      flash[:error] = 'Sorry, that email has already been used. Please <a href="/contact">contact us</a>.'.html_safe
      redirect_to(action: :index) && return
    elsif !@instance_creator
      flash[:error] = 'Sorry, that email was not pre-approved. Please <a href="/contact">contact us</a>.'.html_safe
      redirect_to(action: :index) && return
    end
  end

  def find_or_build_user
    @user = User.find_by(email: @instance_creator.email) || User.new(email: @instance_creator.email)
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end

  def user_params
    params.require(:user).permit(secured_params.user)
  end
end
