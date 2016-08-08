class MoveConfirmReservationsToActionTypes < ActiveRecord::Migration
  def up
    add_column :transactable_type_action_types, :confirm_reservations, :boolean, default: true
    TransactableType::ActionType.reset_column_information
    Instance.find_each do |instance|
      instance.set_context!
      TransactableType.with_deleted.find_each do |tt|
        tt.action_types.each do |at|
          confirm = if at.is_a?(TransactableType::PurchaseAction) || at.is_a?(TransactableType::NoActionBooking)
            false
          elsif tt.availability_options["confirm_reservations"]
            tt.availability_options["confirm_reservations"]["default_value"]
          else
            true
          end
          at.update_column :confirm_reservations, confirm
        end
      end
    end
  end

  def down
    remove_column :transactable_type_action_types, :confirm_reservations
  end
end
