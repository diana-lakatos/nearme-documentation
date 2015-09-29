class AddInsuranceValueToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :insurance_value_cents, :integer
  end
end
