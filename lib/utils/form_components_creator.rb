module Utils
  class FormComponentsCreator
    def initialize(form_componentable, options = {})
      @creator = case form_componentable
                 when ReservationType
                   ReservationComponentCreator
                 when TransactableType
                   if options[:project]
                     ProjectComponentCreator
                   else
                     TransactableComponentCreator
                   end
                 when InstanceProfileType
                   case form_componentable.profile_type
                   when InstanceProfileType::SELLER
                     InstanceSellerProfileCreator
                   when InstanceProfileType::BUYER
                     InstanceBuyerProfileCreator
                   when InstanceProfileType::DEFAULT
                     InstanceDefaultProfileCreator
                   else
                     InstanceProfileCreator
                   end
                 when Instance
                   LocationFormComponentsCreator
                 else
                   raise NotImplementedError, "Invalid form componentable: #{form_componentable.class}"
                 end.new(form_componentable)
    end

    def create!
      @creator.create!
    end
  end

  class BaseComponentCreator
    class AlreadyCreatedError < StandardError; end

    def initialize(form_componentable)
      @form_componentable = form_componentable
    end

    def create!
      raise NotImplementedError
    end

    def create_components!(components, ui_version = nil)
      components.each do |component|
        next if component[:fields].nil?

        options = { name: component[:name], form_type: @form_type_class, form_fields: component[:fields] }
        options[:ui_version] = ui_version if ui_version.present?

        @form_componentable.form_components.create!(options)
      end
    end
  end

  class LocationFormComponentsCreator < BaseComponentCreator
    def create!
      create_location_form_components!
    end

    def create_location_form_components!
      @form_type_class = FormComponent::LOCATION_ATTRIBUTES

      create_components!(
        [
          { name: 'Location',
            fields: [
              { 'location' => 'name' },
              { 'location' => 'address' },
              { 'location' => 'time_zone' },
              { 'location' => 'description' },
              { 'location' => 'location_type' },
              { 'location' => 'email' },
              { 'location' => 'administrator' },
              { 'location' => 'special_notes' },
              { 'location' => 'availability_rules' },
              { 'location' => 'assigned_waiver_agreement_templates' }
            ] }
        ]
      )
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
                             name: 'Review',
                             fields: [
                               { 'reservation' => 'payments' }
                             ]
                           }
                         ])
    end
  end

  class TransactableComponentCreator < BaseComponentCreator
    def create!
      create_space_wizard!
      create_dashboard_form!
    end

    def create_space_wizard!
      @form_type_class = FormComponent::SPACE_WIZARD
      create_components!([
                           {
                             name: I18n.t('registrations.tell_us'),
                             fields: [{ 'user' => 'name' }]
                           },
                           {
                             name: 'Tell us a little about your company',
                             fields: [{ 'company' => 'name' }, { 'company' => 'address' }]
                           },
                           {
                             name: "Where is your #{@form_componentable.name} located?",
                             fields: [{ 'location' => 'name' }, { 'location' => 'description' }, { 'location' => 'address' }, { 'location' => 'location_type' }, { 'location' => 'phone' }]
                           },
                           {
                             name: "Please tell us about the #{@form_componentable.name} you're listing",
                             fields: [{ 'transactable' => 'name' }, { 'transactable' => 'description' }, { 'transactable' => 'listing_type' }, { 'transactable' => 'custom_type' }, { 'transactable' => 'quantity' }, { 'transactable' => 'currency' }, { 'transactable' => 'price' }, { 'transactable' => 'availability_rules' }, { 'transactable' => 'photos' }]
                           },
                           {
                             name: 'And finally, your contact information?',
                             fields: [{ 'user' => 'phone' }]
                           }
                         ])
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::TRANSACTABLE_ATTRIBUTES
      create_components!(
        [
          {
            name: 'Details', fields: %w(name listing_type description photos location_id waiver_agreement_templates documents_upload approval_requests).map { |field| { 'transactable' => field } }
          },
          { name: 'Pricing & Availability', fields: %w(confirm_reservations enabled price schedule availability_rules currency quantity book_it_out exclusive_price action_rfq capacity).map { |field| { 'transactable' => field } } }
        ],
        'new_dashboard'
      )
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
                             fields: [{ 'user' => 'name' }]
                           },
                           {
                             name: "#{@form_componentable.name.try(:pluralize)} Details",
                             fields: [{ 'transactable' => 'name' }, { 'transactable' => 'description' }, { 'transactable' => 'topics' }, { 'transactable' => 'photos' }]
                           }
                         ])
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::TRANSACTABLE_ATTRIBUTES
      create_components!([
                           {
                             name: 'Main',
                             fields: [{ 'transactable' => 'name' }, { 'transactable' => 'description' }, { 'transactable' => 'topics' }, { 'transactable' => 'photos' }]
                           }
                         ])
    end
  end

  class InstanceProfileCreator < BaseComponentCreator
    def create!
    end
  end

  class InstanceDefaultProfileCreator < BaseComponentCreator
    def create!
      create_dashboard_form!
      create_default_registration!
    end

    def create_dashboard_form!
      @form_type_class = FormComponent::INSTANCE_PROFILE_TYPES
      create_components!([
                           {
                             name: 'Profile',
                             fields: [{ 'user' => 'public_profile' }, { 'user' => 'password' }, { 'user' => 'email' }, { 'user' => 'phone' }, { 'user' => 'job_title' }, { 'user' => 'avatar' }, { 'user' => 'biography' }, { 'user' => 'skills_and_interests' }, { 'user' => 'name' }, { 'user' => 'first_name' }, { 'user' => 'middle_name' }, { 'user' => 'last_name' }, { 'user' => 'gender' }, { 'user' => 'drivers_licence_number' }, { 'user' => 'gov_number' }, { 'user' => 'approval_requests' }, { 'user' => 'degree' }, { 'user' => 'language' }, { 'user' => 'time_zone' }, { 'user' => 'company_name' }]
                           }
                         ])
    end

    def create_default_registration!
      @form_type_class = FormComponent::DEFAULT_REGISTRATION
      create_components!([
                           {
                             name: 'Registration',
                             fields: [{ 'user' => 'name' }, { 'user' => 'email' }, { 'user' => 'password' }]
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
                             fields: [{ 'user' => 'name' }, { 'user' => 'email' }, { 'user' => 'password' }]
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
                             fields: [{ 'user' => 'name' }, { 'user' => 'email' }, { 'user' => 'password' }]
                           }
                         ])
    end
  end
end
