class AddListingsPublicToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :listings_public, :boolean, default: true
  end
end
