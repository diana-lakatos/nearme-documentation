class AddHtmlContentToPages < ActiveRecord::Migration

  def up
    add_column :pages, :html_content, :text
  end

  def down
    remove_column :pages, :html_content
  end
end
