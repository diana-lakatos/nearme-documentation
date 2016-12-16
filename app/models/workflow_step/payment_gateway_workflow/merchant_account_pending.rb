class WorkflowStep::PaymentGatewayWorkflow::MerchantAccountPending < WorkflowStep::PaymentGatewayWorkflow::BaseStep
  def initialize(merchant_account_id, error_message=nil)
    @merchant_account = MerchantAccount.find_by_id(merchant_account_id)
  end

  # merchant_account
  #   MerchantAccount object
  # merchantable
  #   Company object
  # error_message
  #   String - combined error messages into one string, obtained from third party payment gateway

  def data
    { merchant_account: @merchant_account, merchantable: @merchant_account.merchantable}
  end
end
