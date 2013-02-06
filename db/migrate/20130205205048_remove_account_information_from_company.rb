class RemoveAccountInformationFromCompany < ActiveRecord::Migration
  def up
    remove_column :companies, :routing_number
    remove_column :companies, :account_number
  end

  def down
    add_column :companies, :account_number, :string
    add_column :companies, :routing_number, :string
  end
end
