class AddDepositCentsToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :deposit_amount_cents, :integer
  end
end
