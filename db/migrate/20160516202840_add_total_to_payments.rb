class AddTotalToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :total_amount_cents, :integer, default: 0

    Payment.update_all("total_amount_cents = (      subtotal_amount_cents + service_fee_amount_guest_cents + service_additional_charges_cents +  host_additional_charges_cents)")
  end
end
