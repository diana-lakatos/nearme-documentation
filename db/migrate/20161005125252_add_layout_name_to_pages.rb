class AddLayoutNameToPages < ActiveRecord::Migration
  class Page < ActiveRecord::Base
  end

  def up
    add_column :pages, :layout_name, :string, default: 'application'
    Page.where(no_layout: true).update_all(layout_name: nil)
  end

  def down
    remove_column :pages, :layout_name
  end

end

