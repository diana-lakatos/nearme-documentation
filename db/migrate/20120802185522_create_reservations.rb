class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.references :listing
      t.references  :owner

      t.string   :state
      t.string   :confirmation_email
      t.integer  :total_amount_cents
      t.string   :currency
      t.datetime :created_at,         :null => false
      t.datetime :updated_at,         :null => false
      t.datetime :deleted_at
    end
  end

  def self.down
    drop_table :reservations
  end
end
