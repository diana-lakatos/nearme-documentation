class MovePagesFromInstanceToTheme < ActiveRecord::Migration
  def change
    remove_column :pages, :instance_id
    add_column :pages, :theme_id, :integer
    add_index :pages, :theme_id
  end
end
