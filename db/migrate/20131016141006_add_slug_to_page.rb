class AddSlugToPage < ActiveRecord::Migration
  class Page < ActiveRecord::Base
  end

  def change
    add_column :pages, :slug, :string

    Page.find_each(&:save)
  end
end
