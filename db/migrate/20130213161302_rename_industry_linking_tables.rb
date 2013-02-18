class RenameIndustryLinkingTables < ActiveRecord::Migration
  def up
    rename_table :companies_industries, :company_industries
    rename_table :industries_users, :user_industries
  end

  def down
    rename_table :company_industries, :companies_industries
    rename_table :user_industries, :industries_users
  end
end
