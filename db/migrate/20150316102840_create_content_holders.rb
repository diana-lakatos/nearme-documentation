class CreateContentHolders < ActiveRecord::Migration
  def change
    create_table :content_holders do |t|
      t.string :name
      t.integer :theme_id
      t.integer :instance_id
      t.text :content
      t.boolean :enabled, default: true
      t.timestamp :deleted_at
      t.timestamps
    end

    add_index :content_holders, [:instance_id, :theme_id, :name]
  end
end
