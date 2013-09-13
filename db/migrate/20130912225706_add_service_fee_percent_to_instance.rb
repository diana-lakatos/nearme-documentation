class AddServiceFeePercentToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :service_fee_percent, :decimal, :precision => 5, :scale => 2, :default => 0
  end
end
