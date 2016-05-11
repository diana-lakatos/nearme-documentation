class CreateJoinTableCountryShippingRule < ActiveRecord::Migration
  def change
    create_join_table :countries, :shipping_rules do |t|
      t.index [:shipping_rule_id, :country_id], name: 'shipping_rule_country_idx'
      t.index [:country_id, :shipping_rule_id], name: 'country_shipping_rule_idx'
    end
  end
end
