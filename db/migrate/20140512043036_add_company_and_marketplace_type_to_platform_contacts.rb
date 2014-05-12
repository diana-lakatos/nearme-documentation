class AddCompanyAndMarketplaceTypeToPlatformContacts < ActiveRecord::Migration
  def change
    add_column :platform_contacts, :company, :string
    add_column :platform_contacts, :marketplace_type, :string
  end
end
