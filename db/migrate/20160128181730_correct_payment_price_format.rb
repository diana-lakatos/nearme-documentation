class CorrectPaymentPriceFormat < ActiveRecord::Migration
  def up
    change_column_default(:payments, :subtotal_amount_cents, 0)
    change_column_default(:reservations, :service_fee_amount_guest_cents, 0)
  end

  def down
  end
end
