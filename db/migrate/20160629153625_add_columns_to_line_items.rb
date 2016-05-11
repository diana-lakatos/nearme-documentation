class AddColumnsToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :service_fee_guest_percent, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :line_items, :service_fee_host_percent, :decimal, precision: 5, scale: 2, default: 0.0
  end
end
