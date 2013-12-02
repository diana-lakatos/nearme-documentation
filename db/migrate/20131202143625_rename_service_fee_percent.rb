class RenameServiceFeePercent < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
  end

  def up
    rename_column :instances, :service_fee_percent, :service_fee_guest_percent
    rename_column :payment_transfers, :service_fee_amount_cents, :service_fee_amount_guest_cents
    rename_column :reservation_charges, :service_fee_amount_cents, :service_fee_amount_guest_cents
    rename_column :reservations, :service_fee_amount_cents, :service_fee_amount_guest_cents


    add_column :instances, :service_fee_host_percent, :decimal, :precision => 5, :scale => 2, :default => 0
    add_column :payment_transfers, :service_fee_amount_host_cents, :integer, :null => false, :default => 0
    Instance.update_all('service_fee_host_percent = 10')
  end

  def down
    rename_column :instances, :service_fee_guest_percent, :service_fee_percent
    rename_column :payment_transfers, :service_fee_amount_guest_cents, :service_fee_amount_cents
    rename_column :reservation_charges, :service_fee_amount_guest_cents, :service_fee_amount_cents
    rename_column :reservations, :service_fee_amount_guest_cents, :service_fee_amount_cents

    remove_column :instances, :service_fee_host_percent
    remove_column :payment_transfers, :service_fee_amount_host_cents
  end
end
