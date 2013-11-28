class AddFaviconImageToTheme < ActiveRecord::Migration
  
  def up
    add_column :themes, :favicon_image, :string

    instance = Instance.where(name: 'DesksNearMe').first
    theme = instance ? instance.theme : nil

    if theme
      io = File.open(File.join(Rails.root, "public", "favicon.ico"), 'rb')

      theme.favicon_image = io 
      theme.save!
    end
  end

  def down
    remove_column :themes, :favicon_image
  end
end
