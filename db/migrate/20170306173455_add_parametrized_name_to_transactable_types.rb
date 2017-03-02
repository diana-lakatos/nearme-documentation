class AddParametrizedNameToTransactableTypes < ActiveRecord::Migration
  def up
    PlatformContext.current = nil
    add_column :transactable_types, :parameterized_name, :string, index: true
    TransactableType.reset_column_information
    TransactableType.find_each { |tt| tt.update_column(:parameterized_name, TransactableType.parameterize_name(tt.name)) }
  end

  def down
    remove_column :transactable_types, :parameterized_name
  end
end
