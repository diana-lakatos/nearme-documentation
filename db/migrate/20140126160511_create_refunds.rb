class CreateRefunds < ActiveRecord::Migration
  def up
    add_column :reservation_charges, :refunded_at, :datetime
    create_table :refunds do |t|
      t.integer :reference_id
      t.string :reference_type
      t.boolean :success
      t.text :encrypted_response
      t.integer :amount
      t.string :currency
      t.datetime :deleted_at
      t.timestamps
    end

  end

  def down
    remove_column :reservation_charges, :refunded_at
    drop_table :refunds
  end
end
