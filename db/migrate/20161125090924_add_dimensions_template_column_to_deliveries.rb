class AddDimensionsTemplateColumnToDeliveries < ActiveRecord::Migration
  def up
    add_column :deliveries, :dimensions_template_id, :integer
  end

  def down
    remove_column :deliveries, :dimensions_template_id, :integer
  end
end
