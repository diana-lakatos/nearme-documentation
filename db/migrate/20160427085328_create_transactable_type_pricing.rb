class CreateTransactableTypePricing < ActiveRecord::Migration
  def change
    create_table :transactable_type_pricings do |t|
      t.integer :instance_id, index: true
      t.string  :action_type
      t.integer :action_id
      t.integer :number_of_units
      t.string  :unit
      t.integer :min_price_cents, default: 0
      t.integer :max_price_cents, default: 0
      t.boolean :allow_exclusive_price
      t.boolean :allow_book_it_out_discount
      t.boolean :allow_free_booking

      t.datetime :deleted_at
      t.timestamps
      t.index [:instance_id, :action_type, :action_id], name: 'action_type_pricings_main_index'
    end
  end
end
