class AddCurrencyFormattingOptionsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :show_currency_symbol, :boolean, default: true, null: false
    add_column :instances, :show_currency_name, :boolean, default: false, null: false
    add_column :instances, :no_cents_if_whole, :boolean, default: true, null: false
  end
end
