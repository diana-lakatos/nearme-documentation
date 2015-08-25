require 'csv'

class Reverse20150825123929 < ActiveRecord::Migration
  def up
    remove_column :countries, :calling_code
    rename_table :countries, :spree_countries
    rename_table :states, :spree_states
  end

  def down
    rename_table :spree_countries, :countries
    rename_table :spree_states, :states

    add_column :countries, :calling_code, :string

    load_countries.each do |pair|
      puts "Update calling code for #{pair[0]}"
      country = Country.where(name: pair[0]).first
      country.update_attribute(:calling_code, pair[1]) if country
    end
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
