class AddAuthorAndTagsToDataSourceContent < ActiveRecord::Migration
  def change
    add_column :data_source_contents, :fields, :text, array: true, default: [], index: true
  end
end
