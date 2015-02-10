class RemoveInstanceTypeIdFromIndexOnInstanceViews < ActiveRecord::Migration
  def up
    remove_index :instance_views, name: 'instance_path_with_format_and_handler'
    add_index :instance_views, [:instance_id, :transactable_type_id, :path, :locale, :format, :handler], name: 'instance_path_with_format_and_handler'
  end

  def down
    remove_index :instance_views, name: 'instance_path_with_format_and_handler'
    add_index :instance_views, [:instance_type_id, :instance_id, :transactable_type_id, :path, :locale, :format, :handler], name: 'instance_path_with_format_and_handler'
  end
end
