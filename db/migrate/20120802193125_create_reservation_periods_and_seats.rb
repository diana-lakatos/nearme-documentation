class CreateReservationPeriodsAndSeats < ActiveRecord::Migration
  def up
    create_table "reservation_periods" do |t|
      t.references  :reservation
      t.references  :listing
      t.date     :date
      t.datetime :created_at,     :null => false
      t.datetime :updated_at,     :null => false
      t.datetime :deleted_at
    end

    create_table "reservation_seats" do |t|
      t.references  :reservation
      t.references  :user
      t.string   :name
      t.string   :email
      t.datetime :created_at,     :null => false
      t.datetime :updated_at,     :null => false
      t.datetime :deleted_at
    end
  end

  def down
    drop_table "reservation_seats"
    drop_table "reservation_periods"
  end
end
