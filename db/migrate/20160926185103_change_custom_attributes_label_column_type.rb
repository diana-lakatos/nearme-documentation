class ChangeCustomAttributesLabelColumnType < ActiveRecord::Migration
  def change
    change_column :custom_attributes, :label, :text
  end
end
