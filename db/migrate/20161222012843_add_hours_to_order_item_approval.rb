class AddHoursToOrderItemApproval < ActiveRecord::Migration
  def change
    add_column :transactable_type_action_types, :hours_to_order_item_approval, :integer
  end
end
