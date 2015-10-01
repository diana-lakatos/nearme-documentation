class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :url
      t.string :image
      t.string :text
      t.integer :instance_id
      t.integer :linkable_id
      t.string :linkable_type
      t.datetime :deleted_at
      t.index [:instance_id, :linkable_id, :linkable_type]
    end
  end
end
