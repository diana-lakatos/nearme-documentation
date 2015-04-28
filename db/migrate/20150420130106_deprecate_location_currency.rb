class DeprecateLocationCurrency < ActiveRecord::Migration

  def change
    rename_column :locations, :currency, :deprecated_currency
  end
end
