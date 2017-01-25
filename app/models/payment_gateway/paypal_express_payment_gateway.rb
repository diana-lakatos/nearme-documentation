class PaymentGateway::PaypalExpressPaymentGateway < PaymentGateway
  include ActionView::Helpers::SanitizeHelper
  include PaymentExtention::PaypalExpressModule

  supported :multiple_currency, :express_checkout_payment, :partial_refunds

  def self.active_merchant_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

  def self.settings
    {
      login: { validate: [:presence] },
      password: { validate: [:presence] },
      signature: { validate: [:presence] },
      # partner_id: { validate: [:presence] }
    }
  end

  def settings_hash
    {
      login: settings[:login],
      password: settings[:password],
      signature: settings[:signature],
      test: test_mode?
    }
  end

  def self.supported_countries
    all_supported_by_pay_pal
  end

  def express_gateway(_merchant_account=nil)
    gateway
  end
end
