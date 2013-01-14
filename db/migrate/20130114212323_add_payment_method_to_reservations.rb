class AddPaymentMethodToReservations < ActiveRecord::Migration
  def up
    add_column :reservations, :payment_method, :string, :null => 'false', :default => 'credit_card'

    # Set the initial payment method to manual for all existing Reservations
    Reservation.update_all(:payment_method => 'manual')
  end

  def down
    remove_column :reservations, :payment_method
  end
end
