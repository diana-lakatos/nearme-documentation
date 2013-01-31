class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :reservation_id
      t.boolean :success
      t.text :response
      t.integer :amount

      t.timestamps
    end
  end
end
