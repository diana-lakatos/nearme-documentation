class AddInstanceIdToPhotos < ActiveRecord::Migration
  class Photo < ActiveRecord::Base
    acts_as_paranoid
    belongs_to :listing, class_name: "Transactable", foreign_key: 'transactable_id'
  end

  class Transactable < ActiveRecord::Base
    acts_as_paranoid
  end

  def change
    add_column :photos, :instance_id, :integer
    add_index :photos, :instance_id

    Photo.with_deleted.find_each do |photo|
      photo.update_column(:instance_id, Transactable.with_deleted.where(id: photo.transactable_id).first.try(:instance_id))
    end
  end
end
