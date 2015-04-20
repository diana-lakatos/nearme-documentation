class AddVoidAtToBillingAuthorization < ActiveRecord::Migration
  def change
    add_column :billing_authorizations, :void_at, :datetime
    add_column :billing_authorizations, :void_response, :text
  end
end
