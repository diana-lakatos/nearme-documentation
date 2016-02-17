class CreateCustomModelTypes < ActiveRecord::Migration
  def change
    create_table :custom_model_types do |t|
      t.string :name
      t.integer :instance_id
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :custom_model_types, [:deleted_at, :instance_id]
  end
end
