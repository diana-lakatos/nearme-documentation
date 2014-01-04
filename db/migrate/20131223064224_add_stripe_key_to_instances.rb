class AddStripeKeyToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :stripe_api_key, :string
    add_column :instances, :stripe_public_key, :string
  end
end
