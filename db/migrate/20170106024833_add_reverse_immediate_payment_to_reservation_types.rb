class AddReverseImmediatePaymentToReservationTypes < ActiveRecord::Migration
  def change
    add_column :reservation_types, :reverse_immediate_payment, :boolean
  end
end
