class AddSkipPaymentAuthorizationToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :skip_payment_authorization, :boolean, default: false
  end
end
