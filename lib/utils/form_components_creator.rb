module Utils
  class FormComponentsCreator

    def initialize(form_componentable)
      @form_componentable = form_componentable
    end

    def create!
      @form_componentable.form_components.destroy_all
      send("create_#{@form_componentable.class.model_name.param_key}_components")
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
      create_component!("Please tell us about the #{@form_componentable.name} you're listing", [{ 'transactable' => 'name' }, { 'transactable' => 'description' }, { 'transactable' => 'listing_type' }, { 'transactable' => 'custom_type' }, { 'transactable' => 'quantity' }, { 'location' => 'currency' }, { 'transactable' => 'price' }, { 'transactable' => 'photos' }])
      create_component!("And finally, your contact information?", [{'user' => 'phone'}])
    end

    def create_product_type_components
      @form_type_class = FormComponent::PRODUCT_ATTRIBUTES
      create_component!("Please in additional product information", [])
    end

    def create_component!(name, form_fields)
      @form_componentable.form_components.create(name: name, form_type: @form_type_class, form_fields: form_fields)
    end

  end
end
