class AddEnablePhotoRequiredToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :enable_photo_required, :boolean, default: true
  end
end
