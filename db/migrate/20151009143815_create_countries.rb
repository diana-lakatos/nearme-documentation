require 'csv'

class CreateCountries < ActiveRecord::Migration
  def up
    create_table :countries do |t|
      Spree::Country.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        t.send(column.type.to_sym, column.name.to_sym,  :null => column.null,
          :limit => column.limit, :default => column.default, :scale => column.scale,
          :precision => column.precision)
      end
      t.string 'calling_code'
    end

    add_index :countries, :iso
    add_index :countries, :name

    Spree::Country.all.each do |m|
      Country.create m.attributes.except(:id)
    end

    load_countries.each do |pair|
      puts "Update calling code for #{pair[0]}"
      country = Country.where(name: pair[0]).first
      country.update_attribute(:calling_code, pair[1]) if country
    end
  end

  def down
    drop_table :countries
  end

  def load_countries
    codes = []
    CSV.foreach(Rails.root.join(*%w(config country_calling_codes.csv)), :headers => :first_row, :return_headers => false) do |row|
      next if row[0].blank? || row[1].blank?
      codes << [row[0], row[1].to_i]
    end
    codes.uniq
  end
end
