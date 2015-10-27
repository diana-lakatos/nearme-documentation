class AddPaymentMethodIdToReservations < ActiveRecord::Migration
  def change
    rename_column :reservations, :payment_method, :old_payment_method
    add_column :reservations, :payment_method_id, :integer
  end
end
