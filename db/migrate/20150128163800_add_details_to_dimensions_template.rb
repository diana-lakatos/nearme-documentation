class AddDetailsToDimensionsTemplate < ActiveRecord::Migration
  def change
    add_column :dimensions_templates, :details, :text
  end
end
