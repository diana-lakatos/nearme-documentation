class Billing::Gateway::Processor::Outgoing::Balanced < Billing::Gateway::Processor::Outgoing::Base

  def setup_api_on_initialize
    Balanced.configure(@instance.billing_gateway_credential('balanced_api_key'))
  end

  def self.create_customer_with_bank_account!(client)
    Balanced.configure(client.instance.balanced_api_key)
    _instance_client = self.instance_client(client, client.instance)
    balanced_customer = nil
    _instance_client.bank_account_last_four_digits = client.last_four_digits_of_bank_account
    if _instance_client.balanced_user_id
      balanced_customer = Balanced::Customer.find(_instance_client.balanced_user_id)
      bank_account = balanced_customer.bank_accounts.last
      bank_account.invalidate
      raise Billing::Gateway::Processor::Base::InvalidStateError.new("Bank account should have been invalidated, but it's still valid for InstanceClient(id=#{_instance_client.id})") if bank_account.is_valid
      balanced_customer = Balanced::Customer.find(_instance_client.balanced_user_id)
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
    raise Billing::Gateway::Processor::Base::InvalidStateError.new('Balanced can payout only USD!') if amount.currency.iso_code != 'USD'
    begin
      @balanced_customer = Balanced::Customer.find(instance_client.balanced_user_id)
      credit = @balanced_customer.credit(
        :amount => amount.cents,
        :description => "Payout from #{@sender.class.name}(id=#{@sender.id}) #{@sender.name} to #{@receiver.class.name}(id=#{@receiver.id}) #{@receiver.name}",
        :appears_on_statement_as => @sender.name.truncate(22, :omission => '')
      ).save
      if credit.status == 'pending' || credit.status ==  'paid' || credit.status ==  'succeeded'
        payout_pending(credit)
      else
        payout_failed(credit)
      end
    rescue Balanced::BadRequest, Balanced::Unauthorized => e
      payout_failed(e)
    end
  end


  private

  def update_payout_status_process(credit_uri)
    setup_api_on_initialize
    credit = Balanced::Credit.fetch(credit_uri)
    if credit.status ==  'paid' || credit.status == 'succeeded'
      payout_successful(credit)
    elsif credit.status == 'pending'
      return false
    else
      payout_failed(credit)
    end
  end

end
