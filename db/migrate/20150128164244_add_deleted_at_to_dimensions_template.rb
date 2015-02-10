class AddDeletedAtToDimensionsTemplate < ActiveRecord::Migration
  def change
    add_column :dimensions_templates, :deleted_at, :datetime
  end
end
