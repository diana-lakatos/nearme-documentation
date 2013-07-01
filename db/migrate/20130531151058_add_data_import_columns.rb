class AddDataImportColumns < ActiveRecord::Migration
  def change
    add_column :companies, :external_id, :string
    add_column :listings, :external_id, :string
    add_column :locations, :address2, :string
    add_column :locations, :postcode, :string
  end

end
