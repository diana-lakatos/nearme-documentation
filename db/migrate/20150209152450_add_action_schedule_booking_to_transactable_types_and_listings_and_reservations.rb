class AddActionScheduleBookingToTransactableTypesAndListingsAndReservations < ActiveRecord::Migration
  def change
    add_column :transactable_types, :action_schedule_booking, :boolean
    add_column :reservations, :type, :string
    add_column :transactables, :action_schedule_booking, :boolean
  end
end
