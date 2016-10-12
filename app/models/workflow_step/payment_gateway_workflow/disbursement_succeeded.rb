class WorkflowStep::PaymentGatewayWorkflow::DisbursementSucceeded < WorkflowStep::PaymentGatewayWorkflow::BaseStep
  def initialize(merchant_account_id, hash)
    @merchant_account = MerchantAccount.find_by_id(merchant_account_id)
    @disbursement = OpenStruct.new(to_liquid: hash)
  end

  # merchant_account
  #   MerchantAccount object
  # merchantable
  #   Company object
  # disbursement
  #  amount - decimal, total amount of the disbursement minus fees
  #  disbursement_date - date object
  #  transaction_ids => array of braintree ids, useful for MPO for double checking purposes
  def data
    { merchant_account: @merchant_account, merchantable: @merchant_account.merchantable, disbursement: @disbursement }
  end
end
