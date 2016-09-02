class AddDeletedAtToAdditionalChargeTypes < ActiveRecord::Migration
  def change
    return if !ActiveRecord::Base.connection.table_exists? 'additional_charge_types'
    add_column :additional_charge_types, :deleted_at, :timestamp
  end
end
