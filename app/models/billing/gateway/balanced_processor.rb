class Billing::Gateway::BalancedProcessor < Billing::Gateway::BaseProcessor
  SUPPORTED_CURRENCIES = ['USD']

  def initialize(instance)
    super(instance)
    Balanced.configure(instance.balanced_api_key)
  end

  def self.currency_supported?(currency)
    self::SUPPORTED_CURRENCIES.include?(currency)
  end

  def self.instance_supported?(instance)
    instance.balanced_api_key.present?
  end

  def store_credit_card(credit_card)
    if user.balanced_user_id.present?
      begin
        @balanced_customer = Balanced::Customer.find(user.balanced_user_id)
        @credit_card = Balanced::Card.new(credit_card.to_balanced_params).save
        @balanced_customer.add_card(@credit_card.uri)

        user.balanced_credit_card_id = @credit_card.uri
        user.save!
      rescue Balanced::NotFound
        setup_customer_with_credit_card(credit_card)
      rescue Balanced::BadRequest => e
        raise Billing::InvalidRequestError, e
      end
    else
      setup_customer_with_credit_card(credit_card)
    end
  rescue Balanced::UnassociatedCardError => e
    raise Billing::CreditCardError, e
  end

  def process_charge(amount)
    begin
      @balanced_customer = Balanced::Customer.find(user.balanced_user_id)
      balanced_charge = @balanced_customer.debit({amount: amount, source_uri: user.balanced_credit_card_id})
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

    # Store customer id against the user
    user.balanced_user_id = @balanced_customer.uri
    user.balanced_credit_card_id = @credit_card.uri
    user.save!
  end

end
