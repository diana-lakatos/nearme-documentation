class AddTaxToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :tax_included_in_price, :boolean, default: :true
    add_column :reservations, :tax_included_in_price, :boolean
    add_column :reservations, :total_tax_amount_cents, :integer
  end
end
