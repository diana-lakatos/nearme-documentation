class AddTargetToDataUpload < ActiveRecord::Migration
  def change
    add_column :data_uploads, :target_id, :integer
    add_column :data_uploads, :target_type, :string
    add_index :data_uploads, [:target_id, :target_type]
  end
end
