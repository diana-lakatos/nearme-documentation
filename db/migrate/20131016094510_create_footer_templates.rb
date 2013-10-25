class CreateFooterTemplates < ActiveRecord::Migration
  def change
    create_table :footer_templates do |t|
      t.text :body
      t.string :path
      t.boolean :partial
      t.references :theme

      t.timestamps
    end
    add_index :footer_templates, :theme_id
    add_index :footer_templates, [:path, :partial, :theme_id]
  end
end
