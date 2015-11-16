class AddTimezoneRuleToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :timezone_rule, :string, default: 'location'
  end
end
