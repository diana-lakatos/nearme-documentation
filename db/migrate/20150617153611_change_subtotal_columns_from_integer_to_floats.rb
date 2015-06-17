class ChangeSubtotalColumnsFromIntegerToFloats < ActiveRecord::Migration
  def change
    change_column :payment_transfers, :service_fee_amount_guest_cents, :decimal, scale: 2, precision: 8
    change_column :payment_transfers, :service_fee_amount_host_cents, :decimal, scale: 2, precision: 8

    change_column :payments, :service_fee_amount_guest_cents, :decimal, scale: 2, precision: 8
    change_column :payments, :service_fee_amount_host_cents, :decimal, scale: 2, precision: 8

    change_column :recurring_bookings, :service_fee_amount_guest_cents, :decimal, scale: 2, precision: 8
    change_column :recurring_bookings, :service_fee_amount_host_cents, :decimal, scale: 2, precision: 8

    change_column :reservations, :service_fee_amount_guest_cents, :decimal, scale: 2, precision: 8
    change_column :reservations, :service_fee_amount_host_cents, :decimal, scale: 2, precision: 8

    change_column :spree_line_items, :service_fee_amount_guest_cents, :decimal, scale: 2, precision: 8
    change_column :spree_line_items, :service_fee_amount_host_cents, :decimal, scale: 2, precision: 8

    change_column :spree_orders, :service_fee_amount_guest_cents, :decimal, scale: 2, precision: 8
    change_column :spree_orders, :service_fee_amount_host_cents, :decimal, scale: 2, precision: 8
  end
end
