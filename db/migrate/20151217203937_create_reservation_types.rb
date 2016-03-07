class CreateReservationTypes < ActiveRecord::Migration
  def change
    create_table :reservation_types do |t|
      t.string :name
      t.integer :instance_id, index: true

      t.timestamp :deleted_at
      t.timestamps null: false
    end
  end
end
