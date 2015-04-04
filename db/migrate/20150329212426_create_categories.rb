class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string  :name
      t.integer :position,    default: 0
      t.integer :instance_id
      t.integer :partner_id
  	  t.integer :user_id
  	  t.integer :parent_id
      t.string  :permalink
      t.text    :description
      t.string  :meta_title
      t.string  :meta_description
      t.string  :meta_keywords
      t.boolean :in_top_nav,        default: false
      t.integer :top_nav_positions
      t.string  :categorable_type
      t.integer :categorable_id
      t.datetime :deleted_at
      t.integer  :lft
      t.integer  :rgt

      t.timestamps
    end

    add_index :categories, :categorable_id
    add_index :categories, :instance_id
    add_index :categories, :partner_id
    add_index :categories, :user_id
    add_index :categories, :parent_id
  end
end
