class AddMissingTypeToChargeTypes < ActiveRecord::Migration
  def change
    ChargeType.where(type: nil).update_all type: "AdditionalChargeType"
  end
end
