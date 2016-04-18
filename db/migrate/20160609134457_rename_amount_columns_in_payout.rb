class RenameAmountColumnsInPayout < ActiveRecord::Migration
  def change
    rename_column :refunds, :amount, :amount_cents
    rename_column :payouts, :amount, :amount_cents
  end
end
