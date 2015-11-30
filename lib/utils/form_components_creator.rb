module Utils
  class FormComponentsCreator

    def initialize(form_componentable)
      @creator = case form_componentable
                 when ServiceType
                   ServiceComponentCreator
                 when Spree::ProductType
                   ProductComponentCreator
                 when ProjectType
                   ProjectComponentCreator
                 when InstanceProfileType
                   case form_componentable.profile_type
                   when InstanceProfileType::SELLER
                     InstanceSellerProfileCreator
                   when InstanceProfileType::BUYER
                     InstanceBuyerProfileCreator
                   when InstanceProfileType::DEFAULT
                     InstanceProfileCreator
                   else
                     raise NotImplementedError
                   end
                 else
                   raise NotImplementedError
                 end.new(form_componentable)
    end

    def create!
      @creator.create!
    end

  end

  class BaseComponentCreator
    class AlreadyCreatedError < StandardError; end;

    def initialize(form_componentable)
      @form_componentable = form_componentable
    end

    def create!
      raise NotImplementedError
    end

    def initial_components_with_user_required_fields
      if @form_componentable.instance.user_info_in_onboarding_flow? && @form_componentable.instance.user_required_fields.count > 0

      else
        []
      end
    end

    def create_components!(components)
      raise AlreadyCreatedError.new("This #{@form_componentable.class} already has form components for #{@form_type_class} populated") if @form_componentable.form_components.where(form_type: @form_type_class).count > 0
      components.each do |component|
        next if component[:fields].nil?
        @form_componentable.form_components.create!(name: component[:name], form_type: @form_type_class, form_fields: component[:fields])
      end
    end

  end

  class ServiceComponentCreator < BaseComponentCreator

    def create!
      create_space_wizard!
      create_dashboard_form!
    end

    def create_space_wizard!
      @form_type_class = FormComponent::SPACE_WIZARD
      create_components!([
        {
          name: I18n.t('registrations.tell_us'),
          fields: @form_componentable.instance.user_required_fields.map { |f| { 'user' => f.to_s } }
        },
        {
          name: 'Tell us a little about your company',
          fields: [ {'company' => 'name'}, {'company' => 'address'}, {'company' => 'industries'} ]
        },
        {
          name: "Where is your #{@form_componentable.name} located?",
          fields: [ { 'location' => 'name'}, { 'location' => 'description'}, { 'location' => 'address'}, { 'location' => 'location_type'}, { 'location' => 'phone'} ]
        },
        {
          name: "Please tell us about the #{@form_componentable.name} you're listing",
          fields: [{ 'transactable' => 'name' }, { 'transactable' => 'description' }, { 'transactable' => 'listing_type' }, { 'transactable' => 'custom_type' }, { 'transactable' => 'quantity' }, { 'transactable' => 'currency' }, { 'transactable' => 'price' }, { 'transactable' => 'photos' } ]
        },
        {
          name: "And finally, your contact information?",
          fields: [{'user' => 'phone'}]
        }
      ])
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::TRANSACTABLE_ATTRIBUTES
      create_components!([{name: 'Main', fields: [{'transactable' => 'location_id'}, {'transactable' => 'approval_requests'}, {'transactable' => 'enabled'}, {'transactable' => 'amenity_types'}, {'transactable' => 'price'}, { 'transactable' => 'currency' }, {'transactable' => 'schedule'}, {'transactable' => 'photos'}, {'transactable' => 'waiver_agreement_templates'}, {'transactable' => 'documents_upload'}, {'transactable' => 'capacity'}, {'transactable' => 'name'}, {'transactable' => 'description'}, {'transactable' => 'quantity'}, { 'transactable' => 'book_it_out' }, { 'transactable' => 'exclusive_price' }, { 'transactable' => 'action_rfq' }, {'transactable' => 'confirm_reservations'}, {'transactable' => 'listing_type'}] }])
    end
  end

  class ProductComponentCreator < BaseComponentCreator

    def create!
      create_space_wizard!
      create_dashboard_form!
    end

    protected

    def create_space_wizard!
      @form_type_class = FormComponent::SPACE_WIZARD
      create_components!([
        {
          name: I18n.t('registrations.tell_us'),
          fields: @form_componentable.instance.user_required_fields.map { |f| { 'user' => f.to_s } }
        },
        {
          name: 'Seller Info',
          fields: [{'company' => 'name'}, {'company' => 'address'}]
        },
        {
          name: "List New #{@form_componentable.name}",
          fields: [ { 'product' => 'name'}, { 'product' => 'description'}, { 'product' => 'photos'}, { 'product' => 'action_rfq' }, { 'product' => 'price'}, { 'product' => 'quantity'}, { 'product' => 'integrated_shipping'}, { 'product' => 'documents_upload'} ]
        },
        {
          name: "#{@form_componentable.name} Specifics",
          fields: @form_componentable.categories.map {|c| {'product' => "Category - #{c.name}"} }
        },
        {
          name: "Shipping Info",
          fields: [{'product' => 'shipping_info'}]
        }
      ])
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::PRODUCT_ATTRIBUTES
      create_components!([
        {
          name: "Main",
          fields: [ { 'product' => 'name'}, { 'product' => 'description'}, { 'product' => 'photos'}, { 'product' => 'action_rfq' }, { 'product' => 'price'}, { 'product' => 'quantity'}, { 'product' => 'integrated_shipping'}, { 'product' => 'documents_upload'}, {'product' => 'shipping_info'} ] + @form_componentable.categories.map {|c| {'product' => "Category - #{c.name}"} }
        }
      ])
    end
  end

  class ProjectComponentCreator < BaseComponentCreator
    def create!
      create_space_wizard!
      create_dashboard_form!
    end

    def create_space_wizard!
      @form_type_class = FormComponent::SPACE_WIZARD
      create_components!([
        {
          name: I18n.t('registrations.tell_us'),
          fields: @form_componentable.instance.user_required_fields.map { |f| { 'user' => f.to_s } }
        },
        {
          name: "#{@form_componentable.name.try(:pluralize)} Details",
          fields: [{ 'project' => 'name' }, { 'project' => 'description' }, { 'project' => 'topics' }, { 'project' => 'photos' } ]
        }
      ])
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::PROJECT_ATTRIBUTES
      create_components!([
        {
          name: "Main",
          fields: [{ 'project' => 'name' }, { 'project' => 'description' }, { 'project' => 'topics' }, { 'project' => 'photos' } ]
        }
      ])
    end
  end

  class InstanceProfileCreator < BaseComponentCreator

    def create!
      create_dashboard_form!
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::INSTANCE_PROFILE_TYPES
      create_components!([
        {
          name: 'Profile',
          fields: [{ "user" => "public_profile" }, { "user" => "password" }, { "user" => "industries" }, { "user" => "email" }, { "user" => "phone" }, { "user" => "job_title" }, { "user" => "avatar" }, { "user" => "biography" }, { "user" => "facebook_url" }, { "user" => "twitter_url" }, { "user" => "linkedin_url" }, { "user" => "instagram_url" }, { "user" => "skills_and_interests" }, { "user" => "name" }, { "user" => "first_name" }, { "user" => "middle_name" }, { "user" => "last_name" }, { "user" => "gender" }, { "user" => "drivers_licence_number" }, { "user" => "gov_number" }, { "user" => "approval_requests" }, { "user" => "google_plus_url" }, { "user" => "degree"}, { "user" => "language" }, { "user" => "time_zone" }, { "user" => "current_location" }, { "user" => "company_name" } ]
        }
      ])
    end
  end

  class InstanceSellerProfileCreator < BaseComponentCreator

    def create!
      create_dashboard_form!
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::SELLER_PROFILE_TYPES
      create_components!([
        {
          name: 'Seller',
          fields: []
        }
      ])
    end
  end

  class InstanceBuyerProfileCreator < BaseComponentCreator

    def create!
      create_dashboard_form!
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::BUYER_PROFILE_TYPES
      create_components!([
        {
          name: 'Buyer',
          fields: []
        }
      ])
    end
  end

end

