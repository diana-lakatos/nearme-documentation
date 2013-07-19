class CreateReservationCharges < ActiveRecord::Migration
  class Reservation < ActiveRecord::Base
  end

  class Charge < ActiveRecord::Base
  end

  class ReservationCharge < ActiveRecord::Base
  end

  def up
    create_table :reservation_charges do |t|
      t.integer :reservation_id
      t.integer :subtotal_amount_cents
      t.integer :service_fee_amount_cents
      t.datetime :paid_at
      t.datetime :failed_at

      t.timestamps
    end

    add_index :reservation_charges, :reservation_id

    # Migrate existing Reservation and Charges to use this new ReservationCharge
    # model. We only care about credit card paid reservations.
    Reservation.where(
      payment_status: 'paid',
      payment_method: 'credit_card'
    ).find_each do |reservation|
      # We need to create a ReservationCharge for this reservation's payment
      # attempt, mark it as paid, and associate all the Charge[Attempt]s to
      # that ReservationCharge.
      reservation_charge = ReservationCharge.create!(
        reservation_id: reservation.id,
        subtotal_amount_cents: reservation.subtotal_amount_cents,
        service_fee_amount_cents: reservation.service_fee_amount_cents,
        paid_at: reservation.created_at,
      )

      # Update any Charges associated with that Reservation payment to this
      # new ReservationCharge.
      Charge.where(
        reference_id: reservation.id,
        reference_type: 'Reservation'
      ).update_all(
        reference_id: reservation_charge.id,
        reference_type: 'ReservationCharge'
      )
    end
  end

  def down
    execute <<-SQL
      UPDATE charges SET
        reference_type = 'Reservation',
        reference_id = (SELECT reservation_id FROM reservation_charges
                        WHERE reservation_charges.id = charges.reference_id)
        WHERE reference_type = 'ReservationCharge'
    SQL

    drop_table :reservation_charges
  end
end
