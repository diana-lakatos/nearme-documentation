class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.integer :instance_id, index: true
      t.string :target_type
      t.integer :target_id
      t.integer :deposit_amount_cents
      t.datetime :authorized_at
      t.datetime :voided_at
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :deposits, [:instance_id, :target_id, :target_type]
  end
end
