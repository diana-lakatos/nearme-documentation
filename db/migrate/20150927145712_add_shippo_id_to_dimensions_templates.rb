class AddShippoIdToDimensionsTemplates < ActiveRecord::Migration
  def change
    add_column :dimensions_templates, :shippo_id, :string
  end
end
