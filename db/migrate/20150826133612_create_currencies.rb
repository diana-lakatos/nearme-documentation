class CreateCurrencies < ActiveRecord::Migration
  def up
    create_table :currencies do |t|
      t.string :symbol
      t.integer :priority
      t.boolean :symbol_first
      t.string :thousands_separator
      t.string :html_entity
      t.string :decimal_mark
      t.string :name
      t.integer :subunit_to_unit
      t.float :exponent
      t.string :iso_code
      t.integer :iso_numeric
      t.string :subunit
      t.integer :smallest_denomination
    end

    add_index :currencies, :iso_code

    attrs = Currency.new.attributes.keys.reject {|k| k == 'id'}

    Money::Currency.all.each do |currency|
      attributes = {}
      attrs.map {|attr| attributes.merge!([[attr, currency.send(attr)]].to_h ) }
      Currency.create!(attributes)
    end
  end

  def down
    drop_table :currencies
  end
end
