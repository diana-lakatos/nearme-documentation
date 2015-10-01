class AddShowCompanyNameToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :show_company_name, :boolean, default: true
  end
end
