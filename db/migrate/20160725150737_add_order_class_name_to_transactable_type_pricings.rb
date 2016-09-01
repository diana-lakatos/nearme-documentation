class AddOrderClassNameToTransactableTypePricings < ActiveRecord::Migration
  def up
    add_column :transactable_type_pricings, :order_class_name, :string

    TransactableType::Pricing.reset_column_information
    Instance.find_each do |instance|
      instance.set_context!
      TransactableType::ActionType.find_each do |at|
        at.pricings.update_all(order_class_name: at.related_order_class)
      end
    end
  end

  def down
    remove_column :transactable_type_pricings, :order_class_name
  end
end
