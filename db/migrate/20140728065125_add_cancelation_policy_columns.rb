class AddCancelationPolicyColumns < ActiveRecord::Migration
  def change
    add_column :transactable_types, :cancellation_policy_enabled, :datetime
    add_column :transactable_types, :cancellation_policy_hours_for_cancellation, :integer, default: 0
    add_column :transactable_types, :cancellation_policy_penalty_percentage, :integer, default: 0
    add_column :reservations, :confirmed_at, :datetime
    add_column :reservations, :cancelled_at, :datetime
    add_column :reservations, :cancellation_policy_hours_for_cancellation, :integer, default: 0
    add_column :reservations, :cancellation_policy_penalty_percentage, :integer, default: 0
    add_column :reservation_charges, :cancellation_policy_hours_for_cancellation, :integer, default: 0
    add_column :reservation_charges, :cancellation_policy_penalty_percentage, :integer, default: 0
  end
end
