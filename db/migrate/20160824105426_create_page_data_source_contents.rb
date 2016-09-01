class CreatePageDataSourceContents < ActiveRecord::Migration
  def change
    create_table :page_data_source_contents do |t|
      t.integer :instance_id
      t.integer :page_id
      t.integer :data_source_content_id
      t.string :slug
      t.timestamps
      t.index [:instance_id, :page_id, :data_source_content_id, :slug], name: 'pdsc_on_foreign_keys'
    end
  end
end
