class AddNoLayoutToPages < ActiveRecord::Migration
  def change
    add_column :pages, :no_layout, :boolean, default: false
  end
end
