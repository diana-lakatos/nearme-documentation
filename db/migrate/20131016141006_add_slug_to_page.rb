class AddSlugToPage < ActiveRecord::Migration
  def change
    add_column :pages, :slug, :string

    Page.find_each(&:save)
  end
end
