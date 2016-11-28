class AddInstanceToTransDimTempl < ActiveRecord::Migration
  def change
    add_column :transactable_dimensions_templates, :instance_id, :integer
  end
end
