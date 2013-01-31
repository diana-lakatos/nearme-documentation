class AddPaymentStatusToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :payment_status, :string, :null => false, :default => 'unknown'
  end
end
