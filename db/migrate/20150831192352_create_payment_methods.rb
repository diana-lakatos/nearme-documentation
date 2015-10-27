class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.integer :payment_gateway_id
      t.integer :instance_id
      t.integer :company_id
      t.integer :partner_id
      t.string :payment_method_type
      t.boolean :active, default: false

      t.timestamps
    end

    add_index :payment_methods, :payment_gateway_id
    add_index :payment_methods, :instance_id
  end
end
