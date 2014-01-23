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

  def self.is_supported_by?(object, role = 'sender')
    super(object, role)
    begin
      if role == 'sender'
        object.balanced_api_key.present?
      elsif role == 'receiver'
        object.balanced_account_number.present? && 
          object.balanced_bank_code.present? &&
          object.balanced_name.present? &&
          object.balanced_type.present?
      end
    rescue
      false
    end
  end

  def process_payout(amount)
    raise 'Balanced can payout only USD!' if amount.currency.iso_code != 'USD'
    begin
      credit = Balanced::Credit.new(
        :amount => amount.cents,
        :description => "Payout from #{@sender.class.name} #{@sender.name}(id=#{@sender.id}) to #{@receiver.class.name} #{@receiver.name} (id=#{@receiver.id})",
        :bank_account => {
          :account_number => @receiver.balanced_account_number,
          :bank_code => @receiver.balanced_bank_code,
          :name => @receiver.balanced_name,
          :type => @receiver.balanced_type
        }
      ).save
      if credit.status == 'pending' || credit.status ==  'paid' || credit.status ==  'succeeded'
        payout_successful(credit)
      else
        payout_failed(credit)
      end
    rescue Balanced::BadRequest => e
      payout_failed(e)
    end
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

end
