class AddHtmlContentToPages < ActiveRecord::Migration

  def up
    add_column :pages, :html_content, :text
    Page.all.each { |p| p.save! } if defined? Page
  end

  def down
    remove_column :pages, :html_content
  end
end
