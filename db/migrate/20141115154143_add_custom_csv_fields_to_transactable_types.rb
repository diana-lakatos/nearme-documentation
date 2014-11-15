class AddCustomCsvFieldsToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :custom_csv_fields, :text
  end
end
