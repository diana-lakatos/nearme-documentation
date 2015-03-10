class AddColumnsToBillingAuthorizations < ActiveRecord::Migration
  def change
    add_column :billing_authorizations, :success, :boolean, default: false
    add_column :billing_authorizations, :encrypted_response, :text
    add_column :billing_authorizations, :user_id, :integer, index: true
  end
end

