# frozen_string_literal: true
class Api::V3::InstancesController < Api::BaseController
  skip_before_action :verified_api_request?
  skip_before_action :require_authorization

  def index
    render json: serialized_collection
  end

  def create
    resource = factory.create
    render json: InstanceJsonSerializer.serialize(resource)
  end

  private

  def require_authentication
    raise DNM::Unauthorized unless valid_token?
  end

  def valid_token?
    request
      .headers['X-APPLICATION-API-TOKEN'] == ENV.fetch('APPLICATION_API_TOKEN')
  end

  def factory
    @factory ||= InstanceFactory.new instance: instance_params,
                                     user: user_params,
                                     creator_email: params[:instance_creator][:email]
  end

  def instance_params
    params.require(:instance).permit(instance_secured_params)
  end

  def user_params
    params.require(:user).permit(secured_params.user)
  end

  def instance_secured_params
    [*secured_params.instance, :id]
  end

  protected

  def serialized_collection
    InstanceJsonSerializer.serialize(
      collection.order('created_at desc'),
      is_collection: true
    )
  end

  def collection
    Instance.includes(:domains, :theme, :users)
  end
end

class InstanceFactory
  attr_reader :instance, :user

  def initialize(params)
    @instance = Instance.new(params[:instance])

    prepare_user params[:creator_email], params[:user][:name]
  end

  def prepare_user(creator_email, user_name)
    @user = User.find_or_initialize_by(email: creator_email)

    if @user.new_record?
      @user.name = user_name
      @password = user.generate_random_password!
    else
      @password = '[using existing account password]'
    end
  end

  def errors
    [user, instance]
      .flat_map { |obj| obj.errors.full_messages.to_sentence }
  end

  def create
    raise ::DNM::Error, 'You must create a domain, e.g. your-market.near-me.com' unless instance.domains.first.present?

    instance.domains.first.use_as_default = true
    instance.theme.support_email = instance.theme.contact_email

    begin
      Instance.transaction do
        instance.save!
        # TODO: tap
        instance.domains.first.update_column(:state, 'elb_secured')
        instance.domains.first.update_column(:secured, true)
        user.save!
        user.update_column(:instance_id, instance.id)
      end
    rescue
      raise ::DNM::Error, errors.join(', ')
    end
    instance.set_context!
    instance.build_availability_templates
    instance.save!

    Utils::FormComponentsCreator.new(instance).create!

    ipt = instance.instance_profile_types.create!(name: 'Default', profile_type: InstanceProfileType::DEFAULT)
    Utils::FormComponentsCreator.new(ipt).create!

    # We remove the profile created on before_create as it's attached to the wrong instance
    begin
      user.default_profile.destroy
    rescue
      user.build_default_profile(instance_profile_type: ipt)
    end
    user.save!

    User.admin.find_each do |user|
      if user.default_profile.blank?
        user.create_default_profile!(
          instance_profile_type: ipt,
          skip_custom_attribute_validation: true
        )
      end
    end

    instance
      .instance_profile_types
      .create!(name: 'Seller', profile_type: InstanceProfileType::SELLER).tap do |type|
      Utils::FormComponentsCreator.new(type).create!
    end

    instance
      .instance_profile_types
      .create!(name: 'Buyer', profile_type: InstanceProfileType::BUYER).tap do |type|
      Utils::FormComponentsCreator.new(type).create!
    end

    create_default_user_message_type
    tp = instance.transactable_types.new(name: instance.bookable_noun)

    tp.action_types << TransactableType::TimeBasedBooking.new(
      transactable_type: tp,
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

    tp.default_availability_template = instance.availability_templates.first
    tp.save!

    tp.create_rating_systems
    Utils::FormComponentsCreator.new(tp).create!

    instance.location_types.create!(name: 'General')

    Utils::DefaultAlertsCreator.new.create_all_workflows!
    InstanceAdmin.create(user_id: user.id)

    blog_instance = BlogInstance.new(name: instance.name + ' Blog')
    blog_instance.owner = instance
    blog_instance.save!

    instance.locales.create! code: instance.primary_locale, primary: true

    WorkflowStepJob.perform(WorkflowStep::InstanceWorkflow::Created, instance.id, user.id, @password, as: user)
    FormComponentToFormConfiguration.new(instance).go!
    instance
  end

  private

  def create_default_user_message_type
    instance.user_message_types.create!(message_type: UserMessageType::DEFAULT)
  end
end
