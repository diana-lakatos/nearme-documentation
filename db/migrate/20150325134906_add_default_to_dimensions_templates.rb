class AddDefaultToDimensionsTemplates < ActiveRecord::Migration
  def change
    add_column :dimensions_templates, :use_as_default, :boolean, default: false
  end
end
