class TurnTransactableTypeToImportableInDataUpload < ActiveRecord::Migration
  def change
    rename_column :data_uploads, :transactable_type_id, :importable_id
    add_column :data_uploads, :importable_type, :string

    remove_index :data_uploads, :importable_id
    add_index :data_uploads, %i(importable_id importable_type)
  end
end
