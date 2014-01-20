class Billing::Gateway::PaypalProcessor < Billing::Gateway::BaseProcessor
  include PayPal::SDK::Core::Logging

  SUPPORTED_CURRENCIES = ['GBP', 'EUR', 'JPY', 'CAD']

  def initialize(instance)
    super(instance)

    PayPal::SDK.configure(
      :mode => DesksnearMe::Application.config.paypal_mode,
      :client_id => instance.paypal_client_id,
      :client_secret => instance.paypal_client_secret,
      :app_id    => instance.paypal_app_id,
      :username  => instance.paypal_username,
      :password  => instance.paypal_password,
      :signature => instance.paypal_signature
    )
    @api = PayPal::SDK::AdaptivePayments::API.new
  end

  def self.currency_supported?(currency)
    self::SUPPORTED_CURRENCIES.include?(currency)
  end

  def self.instance_supported?(instance)
    instance.paypal_username.present? &&
    instance.paypal_password.present? &&
    instance.paypal_signature.present? &&
    instance.paypal_client_id.present? &&
    instance.paypal_client_secret.present? &&
    instance.paypal_app_id.present?
  end

  def self.is_supported_by?(object)
    object.respond_to?(:paypal_email) && object.paypal_email.present?
  end

  def process_charge(amount)
    @payment = PayPal::SDK::REST::Payment.new(paypal_argument_hash(amount))
    if @payment.create
      charge_successful(@payment)
    else
      charge_failed(@payment.error)
      handle_error(@payment.error)
    end
  end

  def process_payout(amount)
    @pay = @api.build_pay({
      :actionType => "PAY",
      :currencyCode => amount.currency.iso_code,
      :feesPayer => "SENDER",
      :cancelUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :returnUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :receiverList => {
        :receiver => [{
          :amount => amount.to_s,
          :email => @receiver.paypal_email 
        }] 
      },
      :senderEmail => @sender.paypal_email
    })
    @pay_response = @api.pay(@pay) 
    if @pay_response.success?
      payout_successful(@pay_response)
    else
      payout_failed(@pay_response.error)
    end
  end

  def store_credit_card(credit_card)
    if user.paypal_id.present?
      update_credit_card(credit_card)
    else
      setup_customer_with_credit_card(credit_card)
    end
  end

  private

  def update_credit_card(credit_card)
    @credit_card = PayPal::SDK::REST::CreditCard.find(user.paypal_id)
  rescue PayPal::SDK::Core::Exceptions::ResourceNotFound
    setup_customer_with_credit_card(credit_card)
  end

  def setup_customer_with_credit_card(credit_card)
    @credit_card = PayPal::SDK::REST::CreditCard.new(
      credit_card.to_paypal_params.merge({
        :payer_id => user.id,
        :first_name => user.first_name, 
        :last_name => user.last_name
      })
    )

    # Make API call & get response status
    # ###Save
    # Creates the credit card as a resource
    # in the PayPal vault. 
    if @credit_card.create
      user.paypal_id = @credit_card.id
      user.save!
    else 
      handle_error(@credit_card.error)
    end

  end

  def handle_error(error_hash)
    if error_hash.present? && error_hash["details"].present?
      first_error_pair = error_hash["details"].first
      message = first_error_pair["issue"]
      param = first_error_pair["field"]
      if message == 'Value is invalid (must be visa, mastercard, amex, discover, or maestro)'
        message = "Unfortunately we do not support your credit card. Please try with Visa, MasterCard, American Express or Discover"
      elsif message.include?("Required field") && param == "type"
        message = "Unfortunately we were not able to detect a type of your credit card. Please make sure that the number is correct"
      end
    else
      message = 'Unknown CreditCard error, please ensure if credit card details were entered correctly. If the problem persist, please contact us.'
      param = nil
    end
    raise Billing::CreditCardError.new(message, param)
  end

  def paypal_argument_hash(amount)
    amount = Money.new(amount, @currency)
    {
      :intent => "sale",
      # Payer
      # A resource representing a Payer that funds a payment
      # Use the List of `FundingInstrument` and the Payment Method
      # as 'credit_card'
      :payer => {
        :payment_method => "credit_card",

        # FundingInstrument
        # A resource representing a Payeer's funding instrument.
        # In this case, a Saved Credit Card can be passed to
        # charge the payment.
        :funding_instruments => [{
          # CreditCardToken
          # A resource representing a credit card that can be
          # used to fund a payment.
          :credit_card_token => {
            :credit_card_id => user.paypal_id,
            :payer_id => user.id }}]
      },

      # Transaction
      # A transaction defines the contract of a
      # payment - what is the payment for and who
      # is fulfilling it
      :transactions => [{

        # Item List
        :item_list => {
          :items => [{
            :name => "Reservation",
            :price => amount,
            :currency => @currency,
            :quantity => 1 }]
        },

        # Amount
        # Let's you specify a payment amount.
        :amount => {
          :total => amount,
          :currency => @currency },
      }]
    }
  end

  def api_config
    @api_config ||= {
      :mode => DesksnearMe::Application.config.paypal_mode,
      :client_id => @instance.paypal_client_id,
      :client_secret => @instance.paypal_client_secret,
      :app_id    => @instance.paypal_app_id,
      :username  => @instance.paypal_username,
      :password  => @instance.paypal_password,
      :signature => @instance.paypal_signature
    }
  end

end
