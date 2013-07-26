class AddPaymentTransferToReservationCharges < ActiveRecord::Migration
  def change
    add_column :reservation_charges, :payment_transfer_id, :integer
    add_index :reservation_charges, :payment_transfer_id
  end
end
