class AddCurrencyToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :currency, :string
  end
end
