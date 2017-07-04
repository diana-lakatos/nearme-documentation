class AddRedirectToSlugToAuthorizationPolicies < ActiveRecord::Migration
  def change
    add_column :authorization_policies, :redirect_to, :string
  end
end
