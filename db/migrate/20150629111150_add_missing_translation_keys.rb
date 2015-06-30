class AddMissingTranslationKeys < ActiveRecord::Migration
  def up
    transactable_types = TransactableType.unscoped.where(deleted_at: nil)
      .joins("left join custom_attributes on custom_attributes.transactable_type_id = transactable_types.id")
      .where("custom_attributes.id is null and custom_attributes.deleted_at is null")
    
    transactable_types.find_each do |tt|
      tt.create_translations!
    end
  end
end
