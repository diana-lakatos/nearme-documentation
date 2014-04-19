class AddStripeCurrencyToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :stripe_currency, :string, :length => 3, :default => 'USD'
  end
end
