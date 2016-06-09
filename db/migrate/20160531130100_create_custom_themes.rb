class CreateCustomThemes < ActiveRecord::Migration
  def change
    create_table :custom_themes do |t|
      t.integer :instance_id
      t.integer :themeable_id
      t.string :themeable_type
      t.string :name
      t.boolean :in_use, default: false
      t.datetime :deleted_at
    end
    add_index :custom_themes, [:instance_id, :themeable_id, :themeable_type], name: 'instance_id_and_themeable'
  end
end
