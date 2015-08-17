class Webhooks::BraintreeMarketplacesController < ApplicationController

  skip_before_filter :redirect_if_marketplace_password_protected
  
  def webhook
    payment_gateway = PaymentGateway.where(type: 'PaymentGateway::BraintreeMarketplacePaymentGateway').first
    raise ActionController::RoutingError.new('Not Found') if payment_gateway.blank?
    payment_gateway.configure_braintree_class

    if request.get? && params[:bt_challenge].present?
      render text: Braintree::WebhookNotification.verify(params[:bt_challenge])
    elsif request.post? && (notification = Braintree::WebhookNotification.parse(params[:bt_signature], params[:bt_payload])).present?
      company = Company.find(notification.merchant_account.id.split('_')[1])
      merchant_account = company.merchant_accounts.where(payment_gateway: payment_gateway).first
      merchant_account.skip_validation = true

      if notification.kind == Braintree::WebhookNotification::Kind::SubMerchantAccountApproved
        merchant_account.webhooks.create!(response: notification.to_yaml)
        merchant_account.verify
      elsif notification.kind == Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined
        merchant_account.webhooks.create!(response: notification.to_yaml)
        merchant_account.fail
      end
      merchant_account.save!
      render nothing: true
    end
  end

end

