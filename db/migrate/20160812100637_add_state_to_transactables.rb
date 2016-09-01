class AddStateToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :state, :string, index: true
    Transactable.reset_column_information
    Transactable.unscoped.update_all(state: 'pending')
  end
end
