class AddInstagramUrlToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :instagram_url, :string
  end
end
