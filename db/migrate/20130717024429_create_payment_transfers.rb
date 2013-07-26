class CreatePaymentTransfers < ActiveRecord::Migration
  def change
    create_table :payment_transfers do |t|
      t.integer :company_id
      t.datetime :transferred_at
      t.string :currency
      t.integer :amount_cents, :null => false, :default => 0
      t.integer :service_fee_amount_cents, :null => false, :default => 0

      t.timestamps
    end

    add_index :payment_transfers, :company_id
  end
end
