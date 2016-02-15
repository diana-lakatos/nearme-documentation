class AddShowPathFormatToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :show_path_format, :string
  end
end

