# frozen_string_literal: true
class AddDirectChargeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :direct_charge, :boolean, default: false

    Payment.reset_column_information
    instance = Instance.find_by(id: 195)
    if instance.present?
      instance.set_context!
      Payment.where.not(merchant_account_id: nil).update_all(direct_charge: true)
    end
  end
end
