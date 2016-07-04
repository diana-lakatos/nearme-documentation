class CreateTransactablePricing < ActiveRecord::Migration
  def change
    create_table :transactable_pricings do |t|
      t.integer :instance_id, index: true
      t.integer :transactable_type_pricing_id
      t.string  :action_type
      t.integer :action_id
      t.integer :number_of_units
      t.string  :unit
      t.integer :price_cents, default: 0
      t.boolean :has_exclusive_price
      t.integer :exclusive_price_cents
      t.boolean :has_book_it_out_discount
      t.integer :book_it_out_discount
      t.integer :book_it_out_minimum_qty
      t.boolean :is_free_booking

      t.datetime :deleted_at
      t.timestamps
      t.index [:instance_id, :action_type, :action_id], name: 'transactable_pricings_main_index'
    end
  end
end
