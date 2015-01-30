module Utils
  class FormComponentsCreator

    def initialize(transactable_type)
      @transactable_type = transactable_type
    end

    def create!
      @transactable_type.form_components.destroy_all
      if @transactable_type.instance.user_info_in_onboarding_flow? && @transactable_type.instance.user_required_fields.count > 0
        form_fields = @transactable_type.instance.user_required_fields.map { |f| { 'user' => f.to_s } }
        create_component!(I18n.t('registrations.tell_us'), form_fields)
      end
      create_component!('Tell us a little about your company', [{'company' => 'name'}, {'company' => 'address'}, {'company' => 'industries'} ])
      create_component!("Where is your #{@transactable_type.name} located?", [ { 'location' => 'name'}, { 'location' => 'description'}, { 'location' => 'address'}, { 'location' => 'location_type'}, { 'location' => 'phone'} ])
      create_component!("Please tell us about the #{@transactable_type.name} you're listing", [{ 'transactable' => 'name' }, { 'transactable' => 'description' }, { 'transactable' => 'listing_type' }, { 'transactable' => 'custom_type' }, { 'transactable' => 'quantity' }, { 'location' => 'currency' }, { 'transactable' => 'price' }, { 'transactable' => 'photos' }])
      create_component!("And finally, your contact information?", [{'user' => 'phone'}])
    end

    protected

    def create_component!(name, form_fields)
      @transactable_type.form_components.create(name: name, form_type: FormComponent::SPACE_WIZARD, form_fields: form_fields)
    end

  end
end
