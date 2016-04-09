class CreateCustomizations < ActiveRecord::Migration
  def change
    create_table :customizations do |t|
      t.integer :instance_id
      t.integer :custom_model_type_id
      t.string :customizable_type
      t.integer :customizable_id
      t.hstore :properties
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :customizations, [:instance_id, :customizable_id, :customizable_type], name: "instance_customizable_index"
  end
end
