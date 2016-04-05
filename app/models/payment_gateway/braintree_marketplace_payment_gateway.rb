class PaymentGateway::BraintreeMarketplacePaymentGateway < PaymentGateway

  supported :any_currency, :company_onboarding, :immediate_payout, :credit_card_payment, :partial_refunds, :host_subscription

  def self.supported_countries
    ['US']
  end

  def self.settings
    {
      merchant_id: "",
      public_key: "",
      private_key: "",
      master_merchant_account_id: ""
    }
  end

  def self.payout_supported_countries
    self.supported_countries
  end

  def settings
    super.merge({environment: test_mode? ? :sandbox : :production })
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::BraintreeMarketplacePayments.new(settings)
  end

  def payment_settled?(token)
    configure_braintree_class
    transaction = Braintree::Transaction.find(token)
    transaction.status == 'settled'
  end

  def verify_webhook(*args)
    gateway.verify(*args)
  end

  def parse_webhook(*args)
    gateway.parse_webhook(*args)
  end

  def find(*args)
    gateway.find(*args)
  end

  def onboard!(*args)
    gateway.onboard!(*args)
  end

  def update_onboard!(*args)
    gateway.update_onboard!(*args)
  end

  def charge(user, amount, currency, payment, token)
    charge_record = super(user, amount, currency, payment, token)
    if charge_record.try(:success?)
      payment_transfer = payment.company.payment_transfers.create!(payments: [payment.reload], payment_gateway_mode: mode, payment_gateway_id: self.id)
      unless payment.payable.billing_authorization.immediate_payout?
        payment_transfer.update_attribute(:transferred_at, nil)
      end
    end
    charge_record
  end

  def payout(*args)
    OpenStruct.new(success: true, success?: true)
  end

  def client_token
    @client_token ||= gateway.client_token
  end

  def refund_identification(charge)
    charge.payment.payable.billing_authorization.token
  end

  def supported_currencies
    settings[:supported_currency]
  end


  def immediate_payout(company)
    merchant_account(company).present?
  end

  def supports_immediate_payout?
    true
  end

  def credit_card_payment?
    true
  end

  private

  def configure_braintree_class
    Braintree::Configuration.environment = settings["environment"]
    Braintree::Configuration.merchant_id = settings["merchant_id"]
    Braintree::Configuration.public_key  = settings["public_key"]
    Braintree::Configuration.private_key = settings["private_key"]
  end
end

