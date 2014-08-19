class AddPricingStructureToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :favourable_pricing_rate, :boolean, default: true
    add_column :transactable_types, :days_for_monthly_rate, :integer, default: 0
  end
end
