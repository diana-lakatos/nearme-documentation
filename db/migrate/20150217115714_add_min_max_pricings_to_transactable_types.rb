class AddMinMaxPricingsToTransactableTypes < ActiveRecord::Migration
  def change
    [:daily, :weekly, :monthly, :hourly, :fixed].each do |price|
      add_column :transactable_types, :"min_#{price}_price_cents", :integer
      add_column :transactable_types, :"max_#{price}_price_cents", :integer
    end
  end
end
