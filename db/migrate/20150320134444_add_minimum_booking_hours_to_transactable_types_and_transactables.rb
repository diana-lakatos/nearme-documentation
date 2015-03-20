class AddMinimumBookingHoursToTransactableTypesAndTransactables < ActiveRecord::Migration
  def up
    add_column :transactable_types, :minimum_booking_minutes, :integer, default: 60
    add_column :transactables, :minimum_booking_minutes, :integer, default: 60
    add_column :reservations, :minimum_booking_minutes, :integer, default: 60
    CustomAttributes::CustomAttribute.unscoped.where(name: 'minimum_booking_minutes').destroy_all
  end

  def down
    remove_column :transactable_types, :minimum_booking_minutes, :integer
    remove_column :transactables, :minimum_booking_minutes, :integer
    remove_column :reservations, :minimum_booking_minutes, :integer

  end
end
