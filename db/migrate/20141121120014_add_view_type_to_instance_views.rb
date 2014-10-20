class AddViewTypeToInstanceViews < ActiveRecord::Migration
  def change
    add_column :instance_views, :view_type, :string
  end
end
