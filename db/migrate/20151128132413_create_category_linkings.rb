class CreateCategoryLinkings < ActiveRecord::Migration
  def change
    create_table :category_linkings do |t|
      t.integer  :category_id
      t.integer  :category_linkable_id
      t.string  :category_linkable_type
      t.integer :instance_id
      t.timestamps
      t.index [:instance_id, :category_linkable_id, :category_linkable_type, :category_id ], name: 'index_category_linkings_on_instance_id_linkable_unique', unique: true
    end
  end
end
