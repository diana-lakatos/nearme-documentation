class ConvertBookingsToReservations < ActiveRecord::Migration
  def up
    add_column :reservations, :booking_id, :integer
    add_column :reservations, :comment, :text
    rename_column :listings, :confirm_bookings, :confirm_reservations
    connection.execute <<-SQL
      INSERT INTO reservations
        (booking_id, listing_id, owner_id, state, comment)
      SELECT id, listing_id, user_id, state, comment
      FROM bookings
    SQL

    connection.execute <<-SQL
      INSERT INTO reservation_periods
        (reservation_id, listing_id, date, created_at, updated_at)
      SELECT r.id, r.listing_id, b.date, b.created_at, b.updated_at
      FROM reservations r
      INNER JOIN bookings b ON r.booking_id = b.id
    SQL

    connection.execute <<-SQL
      INSERT INTO reservation_seats
        (reservation_id, user_id, name, email, created_at, updated_at)
      SELECT r.id, r.owner_id, u.name, u.email, b.created_at, b.updated_at
      FROM reservations r
      INNER JOIN users u ON r.owner_id = u.id
      INNER JOIN bookings b ON r.booking_id = b.id
    SQL

    add_column :feeds, :reservation_id, :integer
    connection.execute <<-SQL
      UPDATE feeds
      SET reservation_id = r.id
      FROM reservations r
      WHERE feeds.booking_id = r.booking_id
    SQL
    remove_column :feeds, :booking_id

    remove_column :reservations, :booking_id

    drop_table :bookings
  end

  def down
    create_table :bookings do |t|
      t.integer  "listing_id"
      t.integer  "reservation_id"
      t.text     "comment"
      t.string   "state"
      t.integer  "user_id"
      t.date     "date"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    connection.execute <<-SQL
      INSERT INTO bookings
        (reservation_id, listing_id, user_id, date, comment, created_at, updated_at)
      SELECT r.id, r.listing_id, r.owner_id, p.date, r.comment, r.created_at, r.updated_at
      FROM reservations r
      INNER JOIN reservation_periods p ON p.reservation_id = r.id
    SQL

    add_column :feeds, :booking_id, :integer
    connection.execute <<-SQL
      UPDATE feeds
      SET booking_id = b.id
      FROM bookings b
      WHERE feeds.reservation_id = b.reservation_id
    SQL
    remove_column :feeds, :reservation_id
    remove_column :reservations, :comment
    rename_column :listings, :confirm_reservations, :confirm_bookings
  end
end
