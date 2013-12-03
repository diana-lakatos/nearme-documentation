class AddFaviconImageToTheme < ActiveRecord::Migration
  
  def up
    add_column :themes, :favicon_image, :string
  end

  def down
    remove_column :themes, :favicon_image
  end
end
