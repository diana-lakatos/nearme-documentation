class AddImmediatePayoutToBillingAuthorizations < ActiveRecord::Migration
  def change
    add_column :billing_authorizations, :immediate_payout, :boolean, default: false
  end
end
