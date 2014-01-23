class AddBalancedDetailsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :encrypted_balanced_account_number, :string
    add_column :companies, :encrypted_balanced_bank_code, :string
    add_column :companies, :encrypted_balanced_name, :string
    add_column :companies, :encrypted_balanced_type, :string
  end
end
