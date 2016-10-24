class RecreateCountriesShippingProfileRulesTable < ActiveRecord::Migration
  def change
    create_table :countries_shipping_rules, id: false, force: :cascade do |t|
      t.integer :country_id,       null: false
      t.integer :shipping_rule_id, null: false
    end

    add_index :countries_shipping_rules, %w(country_id shipping_rule_id), name: 'country_shipping_rule_idx', using: :btree
    add_index :countries_shipping_rules, %w(shipping_rule_id country_id), name: 'shipping_rule_country_idx', using: :btree
  end
end
