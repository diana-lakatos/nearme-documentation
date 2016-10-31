class ImproveWebhooks < ActiveRecord::Migration
  def up
    add_column :webhooks, :payment_gateway_id, :integer, index: true
    add_column :webhooks, :merchant_account_id, :integer, index: true
    add_column :webhooks, :type, :string
    add_column :webhooks, :state, :string
    add_column :webhooks, :error, :text
    add_column :webhooks, :payment_gateway_mode, :string
    add_column :webhooks, :retry_count, :integer, default: 0
    add_column :webhooks, :external_id, :string, index: true

    Webhook.reset_column_information
    webhook_attrs = {}
    Webhook.find_each do |webhook|
      if webhook.webhookable.nil?
        webhook.destroy!
        next
      elsif webhook.webhookable.is_a?(PaymentGateway)
        webhook_attrs[:type] = webhook.webhookable_type.gsub("PaymentGateway", "Webhook")
        webhook_attrs[:payment_gateway_id] = webhook.webhookable_id
      elsif webhook.webhookable.is_a?(MerchantAccount)
        webhook_attrs[:type] = webhook.webhookable_type.gsub("MerchantAccount", "Webhook")
        webhook_attrs[:payment_gateway_id] = webhook.webhookable.payment_gateway_id
      end
      webhook_attrs[:state] = 'archived'
      webhook_attrs[:payment_gateway_mode] = webhook.payment_gateway.try(:mode) || 'test'
      webhook.update_columns(webhook_attrs)
    end
  end

  def down
    remove_column :webhooks, :payment_gateway_id
    remove_column :webhooks, :merchant_account_id
    remove_column :webhooks, :type
    remove_column :webhooks, :state
    remove_column :webhooks, :error
    remove_column :webhooks, :payment_gateway_mode
    remove_column :webhooks, :retry_count
    remove_column :webhooks, :external_id
  end
end
