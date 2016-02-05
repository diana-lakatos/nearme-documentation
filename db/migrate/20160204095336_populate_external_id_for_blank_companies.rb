class PopulateExternalIdForBlankCompanies < ActiveRecord::Migration
  def up
    Company.where(external_id: nil).find_each { |c| c.set_external_id }
  end

  def down
  end
end
