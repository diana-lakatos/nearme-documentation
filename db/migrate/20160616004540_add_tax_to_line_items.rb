class AddTaxToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :additional_tax_total_rate, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :line_items, :additional_tax_price_cents, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :line_items, :included_tax_total_rate, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :line_items, :included_tax_price_cents, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
