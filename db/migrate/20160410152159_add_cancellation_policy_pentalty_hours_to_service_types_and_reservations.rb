class AddCancellationPolicyPentaltyHoursToServiceTypesAndReservations < ActiveRecord::Migration

  def change
    add_column :transactable_types, :cancellation_policy_penalty_hours, :decimal,precision: 8, scale: 2, default: 0
    add_column :transactables, :cancellation_policy_penalty_hours, :decimal,precision: 8, scale: 2, default: 0
    add_column :reservations, :cancellation_policy_penalty_hours, :decimal,precision: 8, scale: 2, default: 0
  end

end
