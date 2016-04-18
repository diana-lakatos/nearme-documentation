class CreateTransactableTypeActionTypes < ActiveRecord::Migration
  def change
    create_table :transactable_type_action_types do |t|
      t.integer :instance_id, index: true
      t.integer :transactable_type_id
      t.boolean :enabled, default: true
      t.datetime :deleted_at
      t.string :type
      t.integer :minimum_booking_minutes, default: 60
      t.boolean :action_continuous_dates_booking
      t.integer :hours_to_expiration, default: 24
      t.datetime :cancellation_policy_enabled
      t.integer :cancellation_policy_hours_for_cancellation, default: 0
      t.integer :cancellation_policy_penalty_percentage, default: 0
      t.integer :cancellation_policy_penalty_hours, default: 0
      t.float :service_fee_guest_percent, default: 0
      t.float :service_fee_host_percent, default: 0
      t.boolean :favourable_pricing_rate
      t.boolean :allow_custom_pricings
      t.boolean :allow_no_action
      t.boolean :allow_action_rfq

      t.timestamps
      t.index [:instance_id, :transactable_type_id, :deleted_at], name: 'instance_tt_deleted_at_idx'
    end
  end
end
