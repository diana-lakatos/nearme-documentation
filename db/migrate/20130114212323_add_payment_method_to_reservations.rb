class AddPaymentMethodToReservations < ActiveRecord::Migration
  def up
    add_column :reservations, :payment_method, :string, :null => false, :default => 'manual'
  end

  def down
    remove_column :reservations, :payment_method
  end
end
