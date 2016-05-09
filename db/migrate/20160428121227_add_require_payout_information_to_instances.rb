class AddRequirePayoutInformationToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :require_payout_information, :boolean, default: false
    add_column :transactables, :possible_payout, :boolean, default: false
  end
end
