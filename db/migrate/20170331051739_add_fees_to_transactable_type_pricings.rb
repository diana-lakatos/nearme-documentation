# frozen_string_literal: true
class AddFeesToTransactableTypePricings < ActiveRecord::Migration
  def change
    add_column :transactable_type_pricings, :service_fee_guest_percent, :integer
    add_column :transactable_type_pricings, :service_fee_host_percent, :integer
  end
end
