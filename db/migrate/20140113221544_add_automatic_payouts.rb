class AddAutomaticPayouts < ActiveRecord::Migration
  def change
    add_column :instances, :paypal_email, :string

    create_table :payouts do |t|
      t.integer :reference_id
      t.string :reference_type
      t.boolean :success
      t.text :response
      t.integer :amount
      t.string :currency
      t.timestamps
    end
  end
end
