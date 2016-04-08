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
                 when OfferType
                   OfferComponentCreator
                 when ReservationType
                   ReservationComponentCreator
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

    def create_components!(components, ui_version = nil)
      raise AlreadyCreatedError.new("This #{@form_componentable.class} already has form components for #{@form_type_class} populated") if @form_componentable.form_components.where(form_type: @form_type_class).count > 0
      components.each do |component|
        next if component[:fields].nil?

        options = { name: component[:name], form_type: @form_type_class, form_fields: component[:fields] }
        options[:ui_version] = ui_version if ui_version.present?

        @form_componentable.form_components.create!(options)
      end
    end

  end

  class OfferComponentCreator < BaseComponentCreator

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
          fields: [{ 'offer' => 'name'}, { 'offer' => 'description'}]
        },
      ])
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::OFFER_ATTRIBUTES

      create_components!([
        {
          name: "Main",
          fields: [{ 'offer' => 'name'}, { 'offer' => 'description'}]
        }
      ])
    end
  end

  class ReservationComponentCreator < BaseComponentCreator

    def create!
      create_dashboard_form!
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::RESERVATION_ATTRIBUTES

      create_components!([
        {
          name: "Review",
          fields: []
        }
      ])
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
      create_components!(
        [
          {
            name: 'Details', fields: %w( name listing_type description amenity_types photos location_id waiver_agreement_templates documents_upload approval_requests ).map {|field| { 'transactable' => field } }
          },
          { name: 'Pricing & Availability', fields: %w( confirm_reservations enabled price schedule currency quantity book_it_out exclusive_price, action_rfq capacity ).map {|field| { 'transactable' => field } }
          }
        ],
        'new_dashboard')
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
      create_default_registration!
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::INSTANCE_PROFILE_TYPES
      create_components!([
        {
          name: 'Profile',
          fields: [{ "user" => "public_profile" }, { "user" => "password" }, { "user" => "industries" }, { "user" => "email" }, { "user" => "phone" }, { "user" => "job_title" }, { "user" => "avatar" }, { "user" => "biography" }, { "user" => "facebook_url" }, { "user" => "twitter_url" }, { "user" => "linkedin_url" }, { "user" => "instagram_url" }, { "user" => "skills_and_interests" }, { "user" => "name" }, { "user" => "first_name" }, { "user" => "middle_name" }, { "user" => "last_name" }, { "user" => "gender" }, { "user" => "drivers_licence_number" }, { "user" => "gov_number" }, { "user" => "approval_requests" }, { "user" => "google_plus_url" }, { "user" => "degree"}, { "user" => "language" }, { "user" => "time_zone" }, { "user" => "company_name" } ]
        }
      ])
    end

    def create_default_registration!
      @form_type_class = FormComponent::DEFAULT_REGISTRATION
      create_components!([
        {
          name: 'Registration',
          fields: [{ "user" => "name" }, { "user" => "email" }, { "user" => "password" } ]
        }
      ])
    end
  end

  class InstanceSellerProfileCreator < BaseComponentCreator

    def create!
      create_dashboard_form!
      create_seller_registration!
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

    def create_seller_registration!
      @form_type_class = FormComponent::SELLER_REGISTRATION
      create_components!([
        {
          name: 'Registration',
          fields: [{ "user" => "name" }, { "user" => "email" }, { "user" => "password" } ]
        }
      ])
    end
  end

  class InstanceBuyerProfileCreator < BaseComponentCreator

    def create!
      create_dashboard_form!
      create_buyer_registration!
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

    def create_buyer_registration!
      @form_type_class = FormComponent::BUYER_REGISTRATION
      create_components!([
        {
          name: 'Registration',
          fields: [{ "user" => "name" }, { "user" => "email" }, { "user" => "password" } ]
        }
      ])
    end
  end

end

