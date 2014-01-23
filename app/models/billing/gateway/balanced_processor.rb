class Billing::Gateway::BalancedProcessor < Billing::Gateway::BaseProcessor
  SUPPORTED_CURRENCIES = ['USD']

  def initialize(*args)
    super(*args)
    Balanced.configure(@instance.balanced_api_key)
  end

  def self.currency_supported?(currency)
    self::SUPPORTED_CURRENCIES.include?(currency)
  end

  def self.instance_supported?(instance)
    instance.balanced_supported?
  end

  def self.is_supported_by?(object, role = 'sender')
    super(object, role)
    begin
      if role == 'sender'
        object.balanced_api_key.present?
      elsif role == 'receiver'
        instance_client(object, object.instance).try(:balanced_user_id).present?
      end
    rescue
      false
    end
  end

  def self.create_customer_with_bank_account(client)
    Balanced.configure(client.instance.balanced_api_key)
    _instance_client = self.instance_client(client, client.instance)
    balanced_customer = nil
    _instance_client.bank_account_last_four_digits = client.last_four_digits_of_bank_account
    if _instance_client.balanced_user_id
      balanced_customer = Balanced::Customer.find(instance_client.balanced_user_id)
      bank_account = @balanced_customer.bank_accounts.last
      bank_account.invalidate
      raise "Bank account should have been invalidated, but it's still valid for InstanceClient(id=#{instance_client.id}" if bank_account.is_valid
      balanced_customer = Balanced::Customer.find(instance_client.balanced_user_id)
    else
      balanced_customer = Balanced::Customer.new(client.to_balanced_params).save
      _instance_client.balanced_user_id = balanced_customer.uri
    end
    bank_account = Balanced::BankAccount.new(client.balanced_bank_account_details).save
    balanced_customer.add_bank_account(bank_account)
    _instance_client.save!
    _instance_client
  end

  def process_payout(amount)
    return if instance_client.balanced_user_id.blank?
    raise 'Balanced can payout only USD!' if amount.currency.iso_code != 'USD'
    @balanced_customer = Balanced::Customer.find(instance_client.balanced_user_id)
    begin
      credit = @balanced_customer.credit(
        :amount => amount.cents,
        :description => "Payout from #{@sender.class.name} #{@sender.name}(id=#{@sender.id}) to #{@receiver.class.name} #{@receiver.name} (id=#{@receiver.id})",
        :appears_on_statement_as => "Payout from #{@sender.class.name}"
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
