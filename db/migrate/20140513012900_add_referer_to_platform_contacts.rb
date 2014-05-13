class AddRefererToPlatformContacts < ActiveRecord::Migration
  def change
    add_column :platform_contacts, :referer, :string
  end
end
