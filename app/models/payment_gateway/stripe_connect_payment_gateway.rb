class PaymentGateway::StripeConnectPaymentGateway < PaymentGateway

  belongs_to :instance
  has_many :merchant_accounts, class_name: 'MerchantAccount::StripeConnectMerchantAccount'

  supported :immediate_payout, :credit_card_payment, :multiple_currency, :partial_refunds

  # def self.supported_countries
  #   %w(AT AU BE CA CH DE DK ES FI FR GB IE IT JP LU MX NL NO SE US)
  # end

  def self.supported_countries
    ["AU", "DK", "FI", "IE", 'NO', 'SE', "US", "GB", "CA"]
  end

  def supported_currencies
    ["AUD", "CAD", "USD", "DKK", "NOK", "SEK", "EUR", "GBP"]
  end

  def self.settings
    { login: '' }
  end

  def settings
    super.merge({environment: test_mode? ? :sandbox : :production})
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::StripeConnectPayments.new(settings)
  end

  def parse_webhook(*args)
    gateway.parse_webhook(*args)
  end

  def retrieve_account(*args)
    gateway.retrieve_account(*args)
  end

  def onboard!(*args)
    gateway.onboard!(*args)
  end

  def update_onboard!(*args)
    gateway.update_onboard!(*args)
  end

  def charge(user, amount, currency, payment, token)
    charge_record = super(user, amount.to_i, currency, payment, token)
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

  def immediate_payout(company)
    merchant_account(company).present?
  end

  def refund_identification(charge)
    charge.payment.payable.billing_authorization.token
  end
end
