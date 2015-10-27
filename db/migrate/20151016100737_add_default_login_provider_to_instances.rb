class AddDefaultLoginProviderToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :default_oauth_signin_provider, :string
  end
end
