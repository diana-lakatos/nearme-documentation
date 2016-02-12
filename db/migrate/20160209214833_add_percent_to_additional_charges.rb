class AddPercentToAdditionalCharges < ActiveRecord::Migration
  def change
    add_column :additional_charge_types, :percent, :integer
  end
end
