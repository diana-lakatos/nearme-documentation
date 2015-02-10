class CreateWishLists < ActiveRecord::Migration
  def change
    create_table :wish_lists do |t|
      t.integer :user_id
      t.integer :instance_id
      t.string :name
      t.boolean :default, default: false

      t.timestamps
    end
  end
end
