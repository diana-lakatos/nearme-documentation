class AddAvailabilityTemplateIdToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :availability_template_id, :integer
  end
end
