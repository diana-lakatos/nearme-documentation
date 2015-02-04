class AddTransactableTypeIdToInstanceViews < ActiveRecord::Migration
  def up
    add_column :instance_views, :transactable_type_id, :integer, index: true
    remove_index :instance_views, name: 'instance_path_with_format_and_handler'
    add_index :instance_views, [:instance_type_id, :instance_id, :transactable_type_id, :path, :locale, :format, :handler], name: 'instance_path_with_format_and_handler'
  end

  def down
    remove_column :instance_views, :transactable_type_id
    add_index :instance_views, [:instance_type_id, :instance_id, :path, :locale, :format, :handler], name: 'instance_path_with_format_and_handler'
  end
end
