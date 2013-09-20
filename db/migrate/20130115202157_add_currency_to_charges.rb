class AddCurrencyToCharges < ActiveRecord::Migration
  def up
    add_column :charges, :currency, :string

    # FIXME: doesn't work
    # execute <<-SQL
    #   UPDATE reservation_charges
    #   INNER JOIN
    #     reservations ON (reservations.id = reservation_charges.reservation_id)
    #   SET
    #     reservation_charges.currency = reservation.currency
    # SQL
  end

  def down
    remove_column :charges, :currency
  end
end
