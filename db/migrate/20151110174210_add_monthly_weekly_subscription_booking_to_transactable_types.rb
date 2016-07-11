class AddMonthlyWeeklySubscriptionBookingToTransactableTypes < ActiveRecord::Migration
  def up
    add_column :transactable_types, :action_weekly_subscription_booking, :boolean
    add_column :transactable_types, :action_monthly_subscription_booking, :boolean

    TransactableType.unscoped.where(action_subscription_booking: true).
      update_all({
        action_weekly_subscription_booking: true,
        action_monthly_subscription_booking: true
      })

    remove_column :transactable_types, :action_subscription_booking
  end

  def down
    add_column :transactable_types, :action_subscription_booking, :boolean

    TransactableType.unscoped.where("action_weekly_subscription_booking IS true or action_monthly_subscription_booking IS true").
      update_all({
        action_subscription_booking: true
      })

    remove_column :transactable_types, :action_weekly_subscription_booking
    remove_column :transactable_types, :action_monthly_subscription_booking
  end
end
