class AddInstanceToTransDimTempl < ActiveRecord::Migration
  def change
    add_column :transactable_dimensions_templates, :instance_id, :integer

    TransactableDimensionsTemplate.reset_column_information
    TransactableDimensionsTemplate.all.find_each do |td|
      td.update_attributes! instance_id: td.dimensions_template.instance_id
    end
  end
end
