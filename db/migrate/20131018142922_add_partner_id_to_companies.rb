class AddPartnerIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :partner_id, :integer
    add_index :companies, :partner_id
  end
end
