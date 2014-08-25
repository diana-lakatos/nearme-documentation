class Billing::Gateway::Processor::Incoming::Base < Billing::Gateway::Processor::Base
  attr_accessor :user

  def initialize(user, instance, currency)
    @client = @user = user
    @instance = instance
    @currency = currency
    ActiveMerchant::Billing::Base.mode = :test if @instance.test_mode?
    setup_api_on_initialize
  end

  def authorize(amount, credit_card, options = {})
    options = options.merge(custom_authorize_options).merge({currency: @currency})
    response = @gateway.authorize(amount, credit_card, options.with_indifferent_access)
    if response.success?
      return {
        token: response.authorization,
        payment_gateway_class: self.class
      }
    else
      return {
        error: response.message
      }
    end
  end

  def charge(amount, reference, token)
    @charge = Charge.create(
      amount: amount,
      reference: reference,
      currency: @currency,
      user_id: @user.id,
    )

    begin
      set_active_merchant_mode(reference)
      options = custom_capture_options.merge(currency: @currency)
      response = @gateway.capture(amount, token, options.with_indifferent_access)

      response.success? ? charge_successful(response.params) : charge_failed(response.params)
      @charge
    rescue => e
      raise Billing::Gateway::PaymentAttemptError, e
    end
  end

  def refund(amount, reference, charge_response)
    @refund = Refund.create(
      amount: amount,
      currency: @currency,
      reference: reference
    )

    raise Billing::Gateway::RefundNotSupportedError, "Refund isn't supported or is not implemented. Please refund this user directly on your gateway account." if !defined?(refund_identification)

    begin
      set_active_merchant_mode(reference)
      options = custom_refund_options.merge(currency: @currency)
      response = @gateway.refund(amount, refund_identification(charge_response), options.with_indifferent_access)
      response.success? ? refund_successful(response.params) : refund_failed(response.params)
      @refund
    rescue => e
      raise Billing::Gateway::PaymentRefundError, e
    end
  end

  def store_credit_card(client, credit_card)
    return nil unless support_recurring_payment?

    @instance_client = client.instance_clients.where(gateway_class: self.class.name).first || client.instance_clients.build
    @instance_client.gateway_class ||= self.class.name
    options = { email: client.email, default_card: true, customer: @instance_client.customer_id }
    response = @gateway.store(credit_card, options)
    @instance_client.response ||= response.to_yaml
    @credit_card = @instance_client.credit_cards.build
    @credit_card.gateway_class ||= self.class.name
    @credit_card.response = response.to_yaml
    @instance_client.save!
    @credit_card.id
  end

  def self.supports_currency?(currency)
    return true if defined? self.support_any_currency!
    self.supported_currencies.include?(currency)
  end

  def support_recurring_payment?
    false
  end

  protected

  def authorize_callbacks(authorization_token, reservation)
    reservation.authorization_token = authorization_token
    reservation.payment_gateway_class = self.class
  end

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    @charge.charge_successful(response)
  end

  # Callback invoked by processor when charge failed
  def charge_failed(response)
    @charge.charge_failed(response)
  end

  # Callback invoked by processor when refund was successful
  def refund_successful(response)
    @refund.refund_successful(response)
  end

  # Callback invoked by processor when refund failed
  def refund_failed(response)
    @refund.refund_failed(response)
  end

  def set_active_merchant_mode(reference)
    if reference.is_a?(Reservation)
      billing_authorization = reference.reservation.billing_authorization
      if billing_authorization.present? && billing_authorization.payment_gateway_mode.present?
        mode = billing_authorization.payment_gateway_mode.to_sym
      else
        mode = :test
      end
      ActiveMerchant::Billing::Base.mode = mode
    else
      ActiveMerchant::Billing::Base.mode = :test if @instance.test_mode?
    end
  end

  def custom_authorize_options
    {}
  end

  def custom_capture_options
    {}
  end

  def custom_refund_options
    {}
  end

end

class Billing::Gateway::PaymentAttemptError < StandardError; end
class Billing::Gateway::PaymentRefundError < StandardError; end
class Billing::Gateway::RefundNotSupportedError < StandardError; end
