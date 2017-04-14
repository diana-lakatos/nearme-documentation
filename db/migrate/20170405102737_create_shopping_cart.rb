# frozen_string_literal: true
class CreateShoppingCart < ActiveRecord::Migration
  def change
    create_table :shopping_carts do |t|
      t.integer :instance_id, null: false
      t.integer :user_id, null: false
      t.datetime :checkout_at
      t.datetime :deleted_at
      t.timestamps null: false
      t.index [:instance_id, :user_id, :checkout_at]
    end
  end
end
