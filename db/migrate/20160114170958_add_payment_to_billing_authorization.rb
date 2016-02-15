class AddPaymentToBillingAuthorization < ActiveRecord::Migration
  def change
    add_column :billing_authorizations, :payment_id, :integer
    add_index :billing_authorizations, :payment_id
  end
end
