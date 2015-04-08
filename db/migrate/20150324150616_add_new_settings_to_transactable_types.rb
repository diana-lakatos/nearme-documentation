class AddNewSettingsToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :skip_location, :boolean
    add_column :transactable_types, :default_currency, :string
    add_column :transactable_types, :allowed_currencies, :text
    add_column :transactable_types, :default_country, :string
    add_column :transactable_types, :allowed_countries, :text
  end
end
