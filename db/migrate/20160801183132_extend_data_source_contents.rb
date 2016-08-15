class ExtendDataSourceContents < ActiveRecord::Migration
  def change
    add_column :data_source_contents, :json_content, :json, default: '{}'
  end
end
