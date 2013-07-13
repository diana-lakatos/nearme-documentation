class SetReservationPriceDefaultsToNil < ActiveRecord::Migration
  def up
    change_column_default :reservations, :service_fee_amount_cents, nil
    change_column_default :reservations, :subtotal_amount_cents, nil
  end

  def down
    change_column_default :reservations, :service_fee_amount_cents, 0
    change_column_default :reservations, :subtotal_amount_cents, 0
  end
end
