class AddNoLayoutToPages < ActiveRecord::Migration
  def change
    add_column :pages, :no_layout, :boolean, default: false
    add_column :pages, :extension, :string
  end
end
