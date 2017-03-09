class AddProRatedToPricings < ActiveRecord::Migration
  def change
    add_column :transactable_pricings, :pro_rated, :boolean, default: false
    add_column :transactable_type_pricings, :pro_rated, :boolean, default: false

    PlatformContext.clear_current
    Transactable::Pricing.reset_column_information
    Transactable::Pricing.where(action_type: "Transactable::SubscriptionBooking", unit: 'subscription_month').update_all(pro_rated: true)
    TransactableType::Pricing.where(action_type: "TransactableType::SubscriptionBooking", unit: 'subscription_month').update_all(pro_rated: true)
  end
end
