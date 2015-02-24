class CreateDocumentsUploads < ActiveRecord::Migration
  def change
    create_table :documents_uploads do |t|
      t.boolean :enabled, default: false
      t.string :requirement
      t.integer  :instance_id, index: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
