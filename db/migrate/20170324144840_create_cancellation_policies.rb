class CreateCancellationPolicies < ActiveRecord::Migration
  def change
    create_table :cancellation_policies, force: :cascade do |t|
      t.integer  :instance_id
      t.string   :action_type
      t.text     :amount_rule
      t.text     :condition
      t.integer  :cancellable_id
      t.string   :cancellable_type
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
    end
  end
end
