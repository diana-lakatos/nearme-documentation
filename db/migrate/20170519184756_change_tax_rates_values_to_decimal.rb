class ChangeTaxRatesValuesToDecimal < ActiveRecord::Migration
  def self.up
    change_column :tax_rates, :value, :decimal, precision: 10, scale: 2
  end

  def self.down
    change_column :tax_rates, :value, :integer
  end
end
