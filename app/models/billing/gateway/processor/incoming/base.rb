class Billing::Gateway::Processor::Incoming::Base < Billing::Gateway::Processor::Base
  attr_accessor :user

  def initialize(user, instance, currency)
    @client = @user = user
    @instance = instance
    @currency = currency
    ActiveMerchant::Billing::Base.mode = :test if @instance.test_mode?
    setup_api_on_initialize
  end

  def authorize(amount, credit_card)
    response = if defined?(custom_authorize_options)
      @gateway.authorize(amount, credit_card, custom_authorize_options)
    else
      @gateway.authorize(amount, credit_card)
    end

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
      response = if defined? (custom_capture_options)
        @gateway.capture(amount, token, custom_capture_options)
      else
        @gateway.capture(amount, token)
      end

      response.success? ? charge_successful(response.params) : charge_failed(response.params)
      return @charge
      
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
      response = if defined?(custom_refund_options)
        @gateway.refund(amount, refund_identification(charge_response), custom_refund_options)
      else
        @gateway.refund(amount, refund_identification(charge_response))
      end

      response.success? ? refund_successful(response.params) : refund_failed(response.params)
      return @refund
    
    rescue => e
      raise Billing::Gateway::PaymentRefundError, e
    end
  end

  def self.supports_currency?(currency)
    return true if defined? self.support_any_currency!
    self.supported_currencies.include?(currency)
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
  
end

class Billing::Gateway::PaymentAttemptError < StandardError; end
class Billing::Gateway::PaymentRefundError < StandardError; end
class Billing::Gateway::RefundNotSupportedError < StandardError; end
