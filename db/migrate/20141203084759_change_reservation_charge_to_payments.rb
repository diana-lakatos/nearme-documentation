class ChangeReservationChargeToPayments < ActiveRecord::Migration
  def up
    add_column :reservation_charges, :reference_type, :string
    add_column :reservation_charges, :reference_id, :integer
    add_index :reservation_charges, [:reference_id, :reference_type]

    connection.execute <<-SQL
      UPDATE reservation_charges
      SET
        reference_id = reservation_id,
        reference_type = 'Reservation'
      WHERE
        reservation_id IS NOT NULL
    SQL

    rename_table :reservation_charges, :payments
  end

  def down
    rename_table :payments, :reservation_charges
    remove_column :reservation_charges, :reference_type
    remove_column :reservation_charges, :reference_id
  end

end

