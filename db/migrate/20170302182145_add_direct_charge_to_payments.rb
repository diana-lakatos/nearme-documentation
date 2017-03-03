class AddDirectChargeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :direct_charge, :boolean, default: false

    Payment.reset_column_information
    Instance.find(195).set_context!

    Payment.where.not(merchant_account_id: nil).update_all(direct_charge: true)
  end
end
