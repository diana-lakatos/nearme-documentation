class RemovelocationsAvailabilityFromFormComponents < ActiveRecord::Migration
  def change
    Instance.find_each do |instance|
      instance.set_context!
      FormComponent.where("form_fields ilike '%location: availability_rules%'").each do |form_component|
        form_component.form_fields.delete_if do |form_field|
          form_field.first == ['location', 'availability_rules']
        end
        form_component.save!
      end
    end
  end
end
