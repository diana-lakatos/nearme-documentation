class CreateCancellationPoliciesConditions < ActiveRecord::Migration
  def change
    create_table :cancellation_policies_conditions do |t|
      t.integer :instance_id
      t.integer :cancellation_policy_id
      t.integer :condition_id
      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
