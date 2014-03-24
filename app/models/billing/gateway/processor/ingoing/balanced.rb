class Billing::Gateway::Processor::Ingoing::Balanced < Billing::Gateway::Processor::Ingoing::Base
  SUPPORTED_CURRENCIES = ['USD']

  def setup_api_on_initialize
    Balanced.configure(@instance.billing_gateway_credential('balanced_api_key'))
  end

  def self.currency_supported?(currency)
    self::SUPPORTED_CURRENCIES.include?(currency)
  end

  def self.instance_supported?(instance)
    instance.balanced_supported?
  end

  def self.is_supported_by?(object)
    instance_client(object, object.instance).try(:balanced_user_id).present?
  end

  def store_credit_card(credit_card)
    if instance_client.balanced_user_id.present?
      begin
        @balanced_customer = Balanced::Customer.find(instance_client.balanced_user_id)
        @credit_card = Balanced::Card.new(credit_card.to_balanced_params).save
        @balanced_customer.add_card(@credit_card.uri)
        instance_client.balanced_credit_card_id = @credit_card.uri
        instance_client.save!
      rescue Balanced::NotFound
        setup_customer_with_credit_card(credit_card)
      end
    else
      setup_customer_with_credit_card(credit_card)
    end
  rescue Balanced::UnassociatedCardError, Balanced::BadRequest, Balanced::Conflict, Billing::InvalidRequestError => e
    handle_error(e)
  end

  def process_refund(amount, charge_response)
    debit = YAML.load(charge_response)
    response = debit.refund
    refund_successful(response)
  rescue
    refund_failed($!)
  end

  def process_charge(amount)
    begin
      @balanced_customer = Balanced::Customer.find(instance_client.balanced_user_id)
      balanced_charge = @balanced_customer.debit({amount: amount, source_uri: instance_client.balanced_credit_card_id})
      charge_successful(balanced_charge)
    rescue
      charge_failed($!)
      # Re-raise for wrapping in custom error wrapper
      raise
    end
  rescue => e
    raise Billing::CreditCardError, e
  end

  private

  # Set up a customer and store their credit card details
  def setup_customer_with_credit_card(credit_card)
    @balanced_customer = Balanced::Customer.new(user.to_balanced_params).save
    @credit_card = Balanced::Card.new(credit_card.to_balanced_params).save
    @balanced_customer.add_card(@credit_card.uri)

    instance_client.balanced_user_id = @balanced_customer.uri
    instance_client.balanced_credit_card_id  = @credit_card.uri
    instance_client.save!
  end

  def handle_error(exception)
    message = ''
    param = ''
    { 
      '[card_number]' => 'number', 
      '[security_code]' => 'cvc', 
      '[expiration_year]' => 'exp_month', 
      '[expiration_month]' => 'exp_month'
    }.each do |balanced_field, our_form_field|
      if exception.message.include?(balanced_field)
        message = exception.message.split("#{balanced_field} - ").last.split(' Your request id is ').first
        param = our_form_field
        break
      end
    end
    if message.blank?
      if exception.message.include?('card-not-validated: Card cannot be validated')
        message = 'Card cannot be validated'
        param = 'number'
      end
    end
    raise Billing::CreditCardError.new(message, param)
  end

end
