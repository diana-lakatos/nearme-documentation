class CreateUploadObligations < ActiveRecord::Migration
  def change
    create_table :upload_obligations do |t|
      t.string :level
      t.references :item, polymorphic: true, index: true
      t.references :instance, index: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :upload_obligations, :deleted_at
  end
end
