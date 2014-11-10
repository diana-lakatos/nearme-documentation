class AddPhoneToPlatformContacts < ActiveRecord::Migration
  def change
    add_column :platform_contacts, :phone, :string
  end
end
