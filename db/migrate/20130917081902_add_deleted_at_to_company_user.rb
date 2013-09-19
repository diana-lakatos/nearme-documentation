class AddDeletedAtToCompanyUser < ActiveRecord::Migration
  def change
    add_column :company_users, :deleted_at, :datetime
  end
end
