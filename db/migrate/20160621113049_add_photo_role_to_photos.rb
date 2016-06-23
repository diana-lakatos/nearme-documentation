class AddPhotoRoleToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :photo_role, :string
  end
end
