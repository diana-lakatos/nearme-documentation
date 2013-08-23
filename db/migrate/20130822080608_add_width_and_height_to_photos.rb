class AddWidthAndHeightToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :width, :integer
    add_column :photos, :height, :integer
    Photo.all.each do |photo|
      photo.width = photo.image.width
      photo.height = photo.image.height
      photo.save!
    end
  end
end
