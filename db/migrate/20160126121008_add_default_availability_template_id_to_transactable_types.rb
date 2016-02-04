class AddDefaultAvailabilityTemplateIdToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :default_availability_template_id, :integer
  end
end
