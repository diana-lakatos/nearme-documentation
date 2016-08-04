class AddDeletedAtToAdditionalChargeTypes < ActiveRecord::Migration
  def change
    add_column :additional_charge_types, :deleted_at, :timestamp
  end
end
