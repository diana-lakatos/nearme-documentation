class MigrateServiceTypeToTransactableType < ActiveRecord::Migration
  def up
    TransactableType.unscoped.where(type: 'ServiceType').update_all(type: 'TransactableType')
    CustomAttributes::CustomAttribute.unscoped.where(target_type: 'ServiceType').update_all(target_type: 'TransactableType')
    CustomValidator.unscoped.where(validatable_type: 'ServiceType').update_all(validatable_type: 'TransactableType')
    DataUpload.unscoped.where(importable_type: 'ServiceType').update_all(importable_type: 'TransactableType')
    FormComponent.unscoped.where(form_componentable_type: 'ServiceType').update_all(form_componentable_type: 'TransactableType')
    CategoryLinking.unscoped.where(category_linkable_type: 'ServiceType').update_all(category_linkable_type: 'TransactableType')
    CustomModelTypeLinking.unscoped.where(linkable_type: 'ServiceType').update_all(linkable_type: 'TransactableType')
    connection.execute("
      UPDATE translations AS tr1
      SET key = regexp_replace(key, '^service_type\.', 'transactable_type.'), updated_at = NOW()
      WHERE tr1.key LIKE 'service_type.%' AND
        NOT EXISTS (SELECT 1 FROM translations tr2
          WHERE tr2.instance_id=tr1.instance_id AND tr1.locale = tr2.locale AND tr2.key = regexp_replace(tr1.key, '^service_type\.', 'transactable_type.') )
    ")
  end
end
