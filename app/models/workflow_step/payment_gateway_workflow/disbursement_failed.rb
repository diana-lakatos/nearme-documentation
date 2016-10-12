class WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed < WorkflowStep::PaymentGatewayWorkflow::BaseStep
  def initialize(merchant_account_id, hash)
    @merchant_account = MerchantAccount.find_by_id(merchant_account_id)
    @disbursement = OpenStruct.new(to_liquid: hash)
  end

  # merchant_account
  #   MerchantAccount object
  # merchantable
  #   Company object
  # disbursement
  #   see https://developers.braintreepayments.com/ios+ruby/reference/general/webhooks/disbursement for details

  def data
    { merchant_account: @merchant_account, merchantable: @merchant_account.merchantable, disbursement: @disbursement }
  end
end
