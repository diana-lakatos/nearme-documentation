class AddStepCheckoutToReservationTypes < ActiveRecord::Migration
  def change
    add_column :reservation_types, :step_checkout, :boolean, default: false
  end
end
