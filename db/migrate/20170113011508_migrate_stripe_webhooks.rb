class MigrateStripeWebhooks < ActiveRecord::Migration
  def up
    Webhook.where(type: 'Webhook::StripeConnectWebhook').update_all(type: 'Webhook::StripeWebhook')
  end

  def down
  end
end
