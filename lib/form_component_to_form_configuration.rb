# frozen_string_literal: true
class FormComponentToFormConfiguration
  ADDRESS_HASH = {
    address: { validation: { presence: {} } },
    should_check_address: {},
    local_geocoding: {},
    latitude: {},
    longitude: {},
    formatted_addres: {},
    street: {},
    suburb: {},
    city: {},
    state: {},
    country: {},
    postcode: {},
    address_components: {},
    validation: { presence: {} }
  }.freeze

  def initialize(instances)
    @instances = instances
  end

  def go!
    @instances.find_each do |i|
      logger.debug "Instance: #{i.name}"
      i.set_context!
      signup_forms!
      update_profile_form!
    end
  end

  protected

  def user_attributes
    @user_attributes ||= (User.columns.map(&:name) + %w(current_address tags mobile_phone password))
  end

  def user_profile_attributes
    @user_profile_attributes ||= UserProfile.columns.map(&:name)
  end

  def update_profile_form!
    logger.debug "\tUpdating Update Profile Forms"
    [
      { Default: FormComponent.where(form_type: 'instance_profile_types', form_componentable: PlatformContext.current.instance.default_profile_type) },
      { Enquirer: FormComponent.where(form_type: 'buyer_profile_types', form_componentable: PlatformContext.current.instance.buyer_profile_type) },
      { Lister: FormComponent.where(form_type: 'seller_profile_types', form_componentable: PlatformContext.current.instance.seller_profile_type) }
    ].each do |el|
      fc_role = el.keys.first

      default_configuration = {}
      enquirer_configuration = {}
      lister_configuration = {}
      el.values.first.each do |form_component|
        if [5011].include?(PlatformContext.current.instance.id)
          logger.debug "Configuration for devmesh/hallmark (#{PlatformContext.current.instance.id})"
          # hardcode fields for devmesh / hallmark :)
          default_configuration.deep_merge!(hallmark_configuration)
        elsif [132].include?(PlatformContext.current.instance.id)
          logger.debug "Configuration for devmesh/hallmark (#{PlatformContext.current.instance.id})"
          # hardcode fields for devmesh / hallmark :)
          default_configuration.deep_merge!(intel_configuration)
        else
          case fc_role
          when :Default
            dc = build_configuration_based_on_form_components(form_component, 'default')
            ec = build_configuration_based_on_form_components(form_component, 'buyer')
            lc = build_configuration_based_on_form_components(form_component, 'seller')
            default_configuration.deep_merge!(dc)
            default_configuration.deep_merge!(ec)
            default_configuration.deep_merge!(lc)

            enquirer_configuration.deep_merge!(ec)

            lister_configuration.deep_merge!(lc)
          when :Enquirer
            dc = build_configuration_based_on_form_components(form_component, 'buyer')
            enquirer_configuration.deep_merge!(dc)
          when :Lister
            dc = build_configuration_based_on_form_components(form_component, 'seller')
            lister_configuration.deep_merge!(dc)
          end
        end
      end
      if [5011, 132].include?(PlatformContext.current.instance.id)
        logger.debug "Configuration for devmesh/hallmark (#{PlatformContext.current.instance.id})"
        # hardcode fields for devmesh / hallmark :)
        create_form_configuration(base_form: UserUpdateProfileForm, name: 'Default Update', configuration: default_configuration)
        create_form_configuration(base_form: UserUpdateProfileForm, name: 'Lister Update', configuration: default_configuration)
        create_form_configuration(base_form: UserUpdateProfileForm, name: 'Enquirer Update', configuration: default_configuration)
      else
        case fc_role
        when :Default
          create_form_configuration(base_form: UserUpdateProfileForm, name: 'Default Update', configuration: default_configuration)
          create_form_configuration(base_form: UserUpdateProfileForm, name: 'Lister Update', configuration: lister_configuration)
          create_form_configuration(base_form: UserUpdateProfileForm, name: 'Enquirer Update', configuration: enquirer_configuration)
        when :Enquirer
          create_form_configuration(base_form: UserUpdateProfileForm, name: 'Enquirer Update', configuration: enquirer_configuration)
        when :Lister
          create_form_configuration(base_form: UserUpdateProfileForm, name: 'Lister Update', configuration: lister_configuration)
        end
      end
    end
  end

  def create_form_configuration(base_form:, name:, configuration:)
    if configuration.present?
      fc = FormConfiguration.where(base_form: base_form).with_parameterized_name(name).first_or_initialize
      fc.configuration = configuration
      fc.save!
    else
      logger.debug "Skipping #{base_form} -> #{name}"
    end
  end

  def build_configuration_based_on_form_components(form_component, role)
    configuration = {}
    if form_component.nil?
      logger.debug "\t\tError: can't find form component"
    else
      logger.debug "\tForm component: #{form_component.form_type}"
      form_component.form_fields.each do |k|
        model = k.keys.first
        field = k.values.last
        # logger.debug "\tProcessing: #{model}: #{field}"
        next if model == 'buyer' && role == 'seller'
        next if model == 'seller' && role == 'buyer'
        next if %w(email).include?(field)

        if model == 'user' && user_attributes.include?(field) || (model == 'buyer' && field == 'tags') || (model == 'user' && field == 'company_name')
          field = 'tag_list' if field == 'tags'
          if field == 'current_address'
            configuration[field.to_sym] = ADDRESS_HASH
          elsif field == 'password' && !form_component.form_type&.include?('_registration')
            configuration[:password_confirmation] ||= {}
            configuration[:password_confirmation][:property_options] ||= { virtual: true }
            configuration[:password_confirmation][:validation] ||= {}
            configuration[:password_confirmation][:validation][:confirm] = {}
          elsif %w(company_name last_name).include?(field)
            configuration[field] = ValidationBuilder.new(PlatformContext.current.instance.default_profile_type, field).build
          else
            configuration['country_name'] = ValidationBuilder.new(PlatformContext.current.instance.default_profile_type, 'country_name').build.deep_merge(ValidationBuilder.new(PlatformContext.current.instance.send("#{role}_profile_type"), 'country_name').build) if field == 'mobile_number' || field == 'phone' || field == 'mobile_phone'
            configuration['mobile_number'] = ValidationBuilder.new(PlatformContext.current.instance.default_profile_type, 'mobile_number').build.deep_merge(ValidationBuilder.new(PlatformContext.current.instance.send("#{role}_profile_type"), 'mobile_number').build) if field == 'phone' || field == 'mobile_phone'
            configuration[field] = ValidationBuilder.new(PlatformContext.current.instance.default_profile_type, field).build.deep_merge(ValidationBuilder.new(PlatformContext.current.instance.send("#{role}_profile_type"), field).build) unless field == 'mobile_phone'
          end
          if %w(name first_name email).include?(field)
            configuration[field][:validation] ||= {}
            configuration[field][:validation][:presence] = {}
          end
        else
          model = 'default' if model == 'user'
          configuration[:profiles] ||= {}
          configuration[:profiles][:"#{model}"] ||= { validation: { presence: {} } }
          if user_profile_attributes.include?(field)
            configuration[:profiles][:"#{model}"][field] = ValidationBuilder.new(PlatformContext.current.instance.send(:"#{model}_profile_type"), field).build
          elsif field == 'unavailable_periods'
            configuration[:profiles][:"#{model}"][:availability_template] = {}
          elsif field.include?('Category -')
            field = field.sub('Category - ', '')
            configuration[:profiles][:"#{model}"][:categories] ||= { validation: { presence: {} } }
            configuration[:profiles][:"#{model}"][:categories][field] = ValidationBuilder.new(Category.find_by(name: field), field).build
          elsif field.include?('Custom Model -')
            field = CustomModelType.parameterize_name(field.sub('Custom Model - ', ''))
            configuration[:profiles][:"#{model}"][:customizations] ||= { validation: { presence: {} } }
            configuration[:profiles][:"#{model}"][:customizations][field] ||= {}
            custom_model_type = CustomModelType.find_by(parameterized_name: field)
            custom_model_type&.custom_attributes&.each do |ca|
              if ca.uploadable?
                if ca.attribute_type == 'photo'
                  configuration[:profiles][:"#{model}"][:customizations][field][:custom_images] ||= {}
                  configuration[:profiles][:"#{model}"][:customizations][field][:custom_images][ca.name] = ValidationBuilder.new(custom_model_type, ca.name).build
                  # if at least one image is required, we need to add validation to custom_images, not only custom_images[<attr.id>]
                  configuration[:profiles][:"#{model}"][:customizations][field][:custom_images][:validation] = { presence: {} } if configuration[:profiles][:"#{model}"][:customizations][field][:custom_images][ca.name][:validation].present?
                elsif ca.attribute_type == 'file'
                  configuration[:profiles][:"#{model}"][:customizations][field][:custom_attachments] ||= {}
                  configuration[:profiles][:"#{model}"][:customizations][field][:custom_attachments][ca.name] = ValidationBuilder.new(custom_model_type, ca.name).build
                  # if at least one attachment is required, we need to add validation to custom_attachments, not only custom_attachments[<attr.id>]
                  configuration[:profiles][:"#{model}"][:customizations][field][:custom_attachments][:validation] = { presence: {} } if configuration[:profiles][:"#{model}"][:customizations][field][:custom_attachments][ca.name][:validation].present?
                else
                  raise NotImplementedError, "Unknown uploadable attribute type: #{ca.attribute_type}"
                end
              else
                configuration[:profiles][:"#{model}"][:customizations][field][:properties] ||= {}
                configuration[:profiles][:"#{model}"][:customizations][field][:properties][ca.name] = ValidationBuilder.new(custom_model_type, ca.name).build
              end
            end
          elsif (ca = PlatformContext.current.instance.send(:"#{model}_profile_type").custom_attributes.where(name: field).first).present?
            if ca.uploadable?
              if ca.attribute_type == 'photo'
                configuration[:profiles][:"#{model}"][:custom_images] ||= {}
                configuration[:profiles][:"#{model}"][:custom_images][ca.name] = ValidationBuilder.new(PlatformContext.current.instance.send(:"#{model}_profile_type"), ca.name).build
                # if at least one image is required, we need to add validation to custom_images, not only custom_images[<attr.id>]
                configuration[:profiles][:"#{model}"][:custom_images][:validation] = { presence: {} } if configuration[:profiles][:"#{model}"][:custom_images][ca.name][:validation].present?
              elsif ca.attribute_type == 'file'
                configuration[:profiles][:"#{model}"][:custom_attachments] ||= {}
                configuration[:profiles][:"#{model}"][:custom_attachments][ca.name] = ValidationBuilder.new(PlatformContext.current.instance.send(:"#{model}_profile_type"), ca.name).build
                # if at least one attachment is required, we need to add validation to custom_attachments, not only custom_attachments[<attr.id>]
                configuration[:profiles][:"#{model}"][:custom_attachments][:validation] = { presence: {} } if configuration[:profiles][:"#{model}"][:custom_attachments][ca.name][:validation].present?
              else
                raise NotImplementedError, "Unknown uploadable attribute type: #{ca.attribute_type}"
              end
            else
              configuration[:profiles][:"#{model}"][:properties] ||= { validation: { presence: {} } }
              configuration[:profiles][:"#{model}"][:properties][field] = ValidationBuilder.new(PlatformContext.current.instance.send(:"#{model}_profile_type"), field).build
            end
          elsif field == 'company_name'
            configuration[field] = ValidationBuilder.new(PlatformContext.current.instance.default_profile_type, field).build
          else
            logger.debug "\t\tSkipping field - #{field}, can't find it"
          end
        end
      end
    end
    configuration
  end

  def intel_configuration
    {
      name: { validation: { presence: {} } },
      cover_image: { validation: {} },
      avatar: { validation: {} },
      current_address: ADDRESS_HASH,
      profiles: {
        default: {
          properties: {
            video_url: { validation: {} },
            short_bio: { validation: {} },
            about_me: { validation: {} }
          }
        }
      }
    }
  end

  def hallmark_configuration
    {
      email: { validation: { presence: {} } },
      name: { validation: { presence: {} } },
      cover_image: { validation: {} },
      avatar: { validation: {} },
      current_address: ADDRESS_HASH,
      profiles: {
        default: {
          properties: {
            short_bio: { validation: {} },
            about_me: { validation: {} }
          }
        }
      }
    }
  end

  def signup_forms!
    logger.debug "\tUpdating Signup Forms"
    { seller: 'Lister', buyer: 'Enquirer', default: 'Default' }.each do |role, conf_role|
      logger.debug "\tform for: #{role}"
      form_component = FormComponent.find_by(form_type: "FormComponent::#{role.upcase}_REGISTRATION".constantize)
      if form_component.nil?
        logger.debug "\t\tError: can't find form component for #{role}"
        next
      end

      base_form = case conf_role
                  when 'Enquirer'
                    UserSignup::EnquirerUserSignup
                  when 'Lister'
                    UserSignup::ListerUserSignup
                  when 'Default'
                    UserSignup::DefaultUserSignup
                  end
      fc = FormConfiguration.where(base_form: base_form, name: "#{conf_role} Signup")
                            .first_or_create!
      configuration = build_configuration_based_on_form_components(form_component, role)
      if PlatformContext.current.instance.force_accepting_tos?
        configuration[:accept_terms_of_service] = { property_options: { virtual: true },
                                                    validation: { acceptance: { allow_nil: false } } }
      end
      configuration.delete([:email, :password])
      fc.update_attribute(:configuration, configuration)
    end
  end

  def logger
    @logger ||= if Rails.env.test?
                  Logger.new('/dev/null')
                else
                  Logger.new($stdout)
                end
  end

  class ValidationBuilder
    def initialize(validatable, field)
      @validatable = validatable
      @field = field
    end

    def build
      if custom_validators.any?
        {
          validation: custom_validators.each_with_object({}) do |cv, validation|
            validation.deep_merge!(cv.validation_rules.deep_symbolize_keys)
          end
        }
      else
        {}
      end
    end

    protected

    def custom_validators
      if @validatable.is_a?(Category)
        if @validatable.mandatory?
          [OpenStruct.new(validation_rules: { presence: true })]
        else
          [OpenStruct.new(validation_rules: {})]
        end
      elsif @validatable.nil?
        [OpenStruct.new(validation_rules: {})]
      else
        (@validatable.custom_attributes.where(name: @field).first || @validatable).custom_validators.where(field_name: @field)
      end
    end
  end
end
