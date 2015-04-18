class AddDefaultCountryToInstance < ActiveRecord::Migration
  def change
  	add_column :instances, :default_country, :string
  	add_column :instances, :allowed_countries, :text
  end
end
