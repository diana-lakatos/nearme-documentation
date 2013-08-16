class AddVersionsGeneratedToPhotos < ActiveRecord::Migration
  class Photo < ActiveRecord::Base
  end

  def change
    add_column :photos, :versions_generated, :boolean, :null => false, :default => false
    Photo.update_all(versions_generated: true)
  end
end
