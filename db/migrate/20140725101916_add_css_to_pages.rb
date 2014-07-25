class AddCssToPages < ActiveRecord::Migration
  def change
    add_column :pages, :css_content, :text
  end
end
