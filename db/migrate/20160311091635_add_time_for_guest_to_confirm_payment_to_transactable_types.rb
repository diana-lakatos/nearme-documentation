class AddTimeForGuestToConfirmPaymentToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :hours_for_guest_to_confirm_payment, :integer, default: 0
  end
end
