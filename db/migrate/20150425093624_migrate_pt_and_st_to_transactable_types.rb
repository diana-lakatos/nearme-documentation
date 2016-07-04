class MigratePtAndStToTransactableTypes < ActiveRecord::Migration

  class ProductType < ActiveRecord::Base
    self.table_name = 'spree_product_types'
    serialize :custom_csv_fields, Array
  end

  def up
    TransactableType.unscoped.where(buyable: true).delete_all

    ProductType.find_each do |pt|
      new_pt = Spree::ProductType.create(
        name: pt.name,
        instance_id: pt.instance_id,
        deleted_at: pt.deleted_at,
        action_rfq: pt.action_rfq,
        manual_payment: pt.possible_manual_payment,
        custom_csv_fields: pt.custom_csv_fields,
        buyable: true
      )
      Spree::Product.unscoped.where(product_type_id: pt.id).update_all(product_type_id: new_pt.id)
      FormComponent.unscoped.where(form_componentable_id: pt.id, form_componentable_type: 'Spree::ProductType').update_all(form_componentable_id: new_pt.id)
      CustomAttributes::CustomAttribute.unscoped.where(target_id: pt.id, target_type: 'Spree::ProductType').update_all(target_id: new_pt.id)
      Category.unscoped.where(categorable_id: pt.id, categorable_type: 'Spree::ProductType').update_all(categorable_id: new_pt.id)
      DataUpload.unscoped.where(importable_id: pt.id, importable_type: 'Spree::ProductType').update_all(importable_id: new_pt.id)
    end

    TransactableType.unscoped.find_each do |tt|
      if tt.type.blank?
        tt.update_column :type, tt.buyable ? 'Spree::ProductType' : 'TransactableType'
      end
    end

  end
end
