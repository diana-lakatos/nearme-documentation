class AddDefaultCurrencyToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :default_currency, :string
    add_column :instances, :allowed_currencies, :text
  end
end
