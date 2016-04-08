class CreateCustomModelTypeLinkings < ActiveRecord::Migration
  def change
    create_table :custom_model_type_linkings do |t|
      t.integer :instance_id
      t.integer :custom_model_type_id
      t.integer :linkable_id
      t.string :linkable_type
      t.index [:instance_id, :linkable_id, :linkable_type], name: "instance_linkable_index"
      t.index [:instance_id, :custom_model_type_id], name: "instance_custom_model_index"
      t.timestamps null: false
    end
  end
end
