# frozen_string_literal: true
class AddDraftToInstanceViews < ActiveRecord::Migration
  def change
    add_column :instance_views, :draft, :boolean, default: false
    remove_index :instance_views, name: 'instance_path_with_format_and_handler'
    add_index :instance_views,
              [:instance_id, :path, :format, :handler, :draft],
              name: 'instance_path_with_format_and_handler'
  end
end
