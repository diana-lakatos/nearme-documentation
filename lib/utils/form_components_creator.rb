module Utils
  class FormComponentsCreator

    def initialize(form_componentable, class_name = nil)
      @form_componentable = form_componentable
      @class_name = class_name
    end

    def create!
      if @class_name.blank?
        if @form_componentable.is_a?(TransactableType)
          @form_componentable.form_components.where(form_type: FormComponent::SPACE_WIZARD).destroy_all
        else
          @form_componentable.form_components.destroy_all
        end
        send("create_#{@form_componentable.class.model_name.param_key}_components")
      elsif @class_name == 'transactable'
        @form_componentable.form_components.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES).destroy_all
        send("create_#{@class_name}_components")
      end
    end

    protected

    def create_transactable_type_components
      @form_type_class = FormComponent::SPACE_WIZARD
      if @form_componentable.instance.user_info_in_onboarding_flow? && @form_componentable.instance.user_required_fields.count > 0
        form_fields = @form_componentable.instance.user_required_fields.map { |f| { 'user' => f.to_s } }
        create_component!(I18n.t('registrations.tell_us'), form_fields)
      end
      create_component!('Tell us a little about your company', [{'company' => 'name'}, {'company' => 'address'}, {'company' => 'industries'} ])
      create_component!("Where is your #{@form_componentable.name} located?", [ { 'location' => 'name'}, { 'location' => 'description'}, { 'location' => 'address'}, { 'location' => 'location_type'}, { 'location' => 'phone'} ])
      create_component!("Please tell us about the #{@form_componentable.name} you're listing", [{ 'transactable' => 'name' }, { 'transactable' => 'description' }, { 'transactable' => 'listing_type' }, { 'transactable' => 'custom_type' }, { 'transactable' => 'quantity' }, { 'transactable' => 'currency' }, { 'transactable' => 'price' }, { 'transactable' => 'photos' }])
      create_component!("And finally, your contact information?", [{'user' => 'phone'}])
    end

    def create_product_type_components
      @form_type_class = FormComponent::PRODUCT_ATTRIBUTES
    end

    def create_transactable_components
      @form_type_class = FormComponent::TRANSACTABLE_ATTRIBUTES
      create_component!('Main', [{'transactable' => 'location_id'}, {'transactable' => 'approval_requests'}, {'transactable' => 'enabled'}, {'transactable' => 'amenity_types'}, {'transactable' => 'price'}, {'transactable' => 'schedule'}, {'transactable' => 'photos'}, {'transactable' => 'waiver_agreement_templates'}, {'transactable' => 'documents_upload'}, {'transactable' => 'capacity'}, {'transactable' => 'name'}, {'transactable' => 'description'}, {'transactable' => 'quantity'}, {'transactable' => 'confirm_reservations'}, {'transactable' => 'listing_type'}])
    end

    def create_component!(name, form_fields)
      @form_componentable.form_components.create(name: name, form_type: @form_type_class, form_fields: form_fields)
    end

  end
end
