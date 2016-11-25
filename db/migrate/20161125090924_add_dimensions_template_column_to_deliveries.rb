class AddDimensionsTemplateColumnToDeliveries < ActiveRecord::Migration
  def up
    add_column :deliveries, :dimensions_template_id, :integer

    Delivery.reset_column_information
    Delivery.all.find_each do |d|
      d.update_attributes!(dimensions_template_id: d.order.transactable.dimensions_template.id)
    end
  end

  def down
    remove_column :deliveries, :dimensions_template_id, :integer
  end
end
