class MakeInstanceViewIndexUnique < ActiveRecord::Migration
  def change
    remove_index :instance_views, name: 'instance_path_with_format_and_handler'
    add_index :instance_views, [:instance_id, :transactable_type_id, :path, :locale, :format, :handler], name: 'instance_path_with_format_and_handler', unique: true
  end
end
