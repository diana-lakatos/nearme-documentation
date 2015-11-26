class AddUpsellToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :service_additional_charges_cents, :decimal, default: 0
    add_column :payments, :host_additional_charges_cents, :decimal, default: 0
  end
end
