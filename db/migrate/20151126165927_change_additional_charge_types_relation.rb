class ChangeAdditionalChargeTypesRelation < ActiveRecord::Migration
  def change
    add_column :additional_charge_types, :additional_charge_type_target_id, :integer
    add_column :additional_charge_types, :additional_charge_type_target_type, :string
    add_index :additional_charge_types,
      [:additional_charge_type_target_id, :additional_charge_type_target_type],
      name: "act_target"
  end
end
