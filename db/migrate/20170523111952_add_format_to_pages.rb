class AddFormatToPages < ActiveRecord::Migration
  def change
    add_column :pages, :format, :integer, default: 0

    remove_index :pages, column: [:slug, :theme_id]
    add_index :pages, [:slug, :theme_id, :format], unique: true, where: '(deleted_at IS NULL)'
  end
end
