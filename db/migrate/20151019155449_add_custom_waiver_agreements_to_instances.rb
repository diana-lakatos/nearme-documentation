class AddCustomWaiverAgreementsToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :custom_waiver_agreements, :boolean, default: true
  end
end
