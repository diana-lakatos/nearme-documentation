class AddCustomPageToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :custom_page, :string
  end
end
