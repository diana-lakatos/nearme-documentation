class AddServiceFeeAndRenameTotalToSubTotalOnReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :service_fee_amount_cents, :integer, :default => 0
    rename_column :reservations, :total_amount_cents, :subtotal_amount_cents
  end
end
