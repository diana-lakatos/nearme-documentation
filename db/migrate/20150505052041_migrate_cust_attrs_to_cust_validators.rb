class MigrateCustAttrsToCustValidators < ActiveRecord::Migration
  def up
    CustomAttributes::CustomAttribute.unscoped.where(deleted_at: nil, name: ['name', 'description', 'confirm_reservations', 'last_request_photos_sent_at', 'capacity']).find_each do |attribute|
      if attribute.validation_rules.present? || attribute.valid_values.present?
        CustomValidator.create!(
          field_name: attribute.name,
          instance_id: attribute.instance_id,
          validatable: attribute.target,
          validation_rules: attribute.validation_rules,
          valid_values: attribute.valid_values
        ) if attribute.target
      end
    end

    CustomAttributes::CustomAttribute.unscoped.where(deleted_at: nil, target_type: 'TransactableType', name: ['name', 'description']).find_each do |attribute|
      t = attribute.instance.translations.find_or_initialize_by(key: "simple_form.labels.transactable.#{attribute.name}", locale: 'en')
      t.value = attribute.label
      t.save!
    end

    CustomAttributes::CustomAttribute.unscoped.where(
      deleted_at: nil,
      target_type: 'TransactableType',
      name: ['name', 'description', 'confirm_reservations', 'last_request_photos_sent_at', 'capacity']
    ).destroy_all
  end
end
