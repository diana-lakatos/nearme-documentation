class CreateCustomThemeAssets < ActiveRecord::Migration
  def change
    create_table :custom_theme_assets do |t|
      t.integer :instance_id
      t.integer :custom_theme_id
      t.string :name
      t.text :comment
      t.string :file
      t.string :external_url
      t.text :body
      t.datetime :deleted_at
      t.hstore :settings
      t.string :type
    end
    add_index :custom_theme_assets, [:instance_id, :custom_theme_id, :name], unique: true, where: '(deleted_at IS NULL)', name: 'cta_on_instance_id_theme_and_name_uniq'
  end
end

