class AddListingsPublicIndexToCompanies < ActiveRecord::Migration
  def change
    add_index :companies, [:instance_id, :listings_public]
    remove_index :companies, :instance_id # Remove redundant index
  end
end
