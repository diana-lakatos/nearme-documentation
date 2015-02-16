class CreateWishListItems < ActiveRecord::Migration
  def change
    create_table :wish_list_items do |t|
      t.integer :instance_id
      t.integer :wish_list_id
      t.belongs_to :wishlistable, polymorphic: true

      t.timestamps
    end

    add_index :wish_list_items, [:instance_id, :wish_list_id]
    add_index :wish_list_items, [:wishlistable_id, :wishlistable_type]
  end
end
