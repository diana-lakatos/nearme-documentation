class AddPaymentTransferIdAndCentsToSpreeLineItem < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :payment_transfer_id, :integer
    add_column :spree_line_items, :service_fee_amount_guest_cents, :decimal, :precision => 5, :scale => 2, :default => 0
    add_column :spree_line_items, :service_fee_amount_host_cents, :decimal, :precision => 5, :scale => 2, :default => 0
  end
end
