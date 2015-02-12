class CreateAdditionalCharges < ActiveRecord::Migration
  def change
    create_table :additional_charges do |t|
      t.string  :name
      t.integer :amount_cents
      t.string  :currency
      t.string  :commission_for
      t.integer :additional_charge_type_id
      t.integer :instance_id
      t.integer :target_id
      t.string :target_type
      t.timestamps
    end
    add_index :additional_charges, :additional_charge_type_id
    add_index :additional_charges, :target_id
    add_index :additional_charges, :instance_id
  end
end
