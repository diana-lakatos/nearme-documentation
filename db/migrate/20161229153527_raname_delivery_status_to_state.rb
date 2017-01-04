class RanameDeliveryStatusToState < ActiveRecord::Migration
  def change
    rename_column :deliveries, :status, :state
  end
end
