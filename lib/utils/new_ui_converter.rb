class NewUiConverter

  def initialize(instance_id)
    @instance = Instance.find instance_id
  end

  def convert_to_new_ui
    @instance.priority_view_path = "new_ui"
    @instance.service_types.find_each do |service_type|
      if service_type.form_components.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES).where("ui_version is NULL or ui_version = 'old_dashboard'").any?
        @old_forms = service_type.form_components.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES).where("ui_version is NULL or ui_version = 'old_dashboard'")
        create_form_component! service_type, 'Details', %w( name listing_type description amenity_types photos location_id waiver_agreement_templates documents_upload approval_requests other_custom_attributes)
        create_form_component! service_type, 'Pricing & Availability', %w( confirm_reservations enabled price schedule currency quantity book_it_out exclusive_price, action_rfq capacity rental_shipping_type )
        @old_forms.update_all ui_version: 'old_dashboard'
        @old_forms.destroy_all
      end
      schedule = service_type.schedule
      if schedule && schedule.schedule_rules.count == 0 && schedule.use_simple_schedule
        schedule.schedule_rules.create!(
          run_hours_mode: ScheduleRule::RECURRING_MODE,
          time_start: schedule.sr_from_hour,
          time_end: schedule.sr_to_hour,
          every_hours: schedule.sr_every_hours || 2,
          run_dates_mode: ScheduleRule::RECURRING_MODE,
          week_days: schedule.sr_days_of_week.presence || (1..5).to_a
        )
      end
    end
    @instance.save!
    true
  end

  def revert_to_old_ui
    @instance.priority_view_path = nil
    @instance.save!
    @instance.service_types.find_each do |service_type|
      old_forms = service_type.form_components.only_deleted.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES, ui_version: 'old_dashboard')
      if old_forms.any?
        old_forms.each do |old_form|
          old_form.deleted_at = nil
          old_form.save!
        end
        new_ui_forms = service_type.form_components.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES).where.not(ui_version: 'old_dashboard')
        new_ui_forms.destroy_all
      else
        return false
      end
    end
    true
  end

  private

  def create_form_component!(service_type, name, fields)
    service_type.form_components.create!(
      name: name,
      form_type: FormComponent::TRANSACTABLE_ATTRIBUTES,
      form_fields: generate_form_fields_array(service_type, fields),
      ui_version: 'new_dashboard'
    )
  end

  def generate_form_fields_array(service_type, fields)
    if 'other_custom_attributes'.in? fields
      custom_attributes = Transactable.public_custom_attributes_names(service_type.id).map { |k| Hash === k ? k.keys : k }.flatten +
        service_type.categories.roots.map { |k| ('Category - ' + k.name) }.flatten
      fields += custom_attributes
    end
    (@old_forms.map(&:fields_names).flatten.uniq & fields).map do |field|
      { "transactable" => field }
    end.compact.uniq
  end

end

