class AddHideAdditionalChargesOnListingPageToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :hide_additional_charges_on_listing_page, :boolean, default: false, null: false
  end
end
