class AddCreateCompanyOnSignUpToInstanceProfileTypes < ActiveRecord::Migration
  def change
    add_column :instance_profile_types, :create_company_on_sign_up, :boolean, default: false
  end
end
