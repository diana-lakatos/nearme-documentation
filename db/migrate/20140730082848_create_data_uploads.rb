class CreateDataUploads < ActiveRecord::Migration
  def change
    create_table :data_uploads do |t|
      t.string :csv_file
      t.string :xml_file
      t.text :options
      t.datetime :imported_at
      t.integer :instance_id
      t.integer :uploader_id
      t.integer :transactable_type_id
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :data_uploads, :instance_id
    add_index :data_uploads, :transactable_type_id
  end
end
