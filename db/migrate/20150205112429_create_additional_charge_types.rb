class CreateAdditionalChargeTypes < ActiveRecord::Migration
  def change
    create_table :additional_charge_types do |t|
      t.string    :name
      t.text      :description
      t.integer   :amount_cents
      t.string    :currency
      t.string    :commission_for
      t.integer   :provider_commission_percentage
      t.string    :status
      t.integer   :instance_id
      t.timestamps
    end
    add_index :additional_charge_types, :instance_id
  end
end
