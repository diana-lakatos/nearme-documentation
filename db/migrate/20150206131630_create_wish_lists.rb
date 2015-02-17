class CreateWishLists < ActiveRecord::Migration
  def change
    create_table :wish_lists do |t|
      t.integer :user_id
      t.integer :instance_id
      t.string :name
      t.boolean :default, default: false

      t.timestamps
    end

    add_index :wish_lists, [:instance_id, :user_id]
  end
end
