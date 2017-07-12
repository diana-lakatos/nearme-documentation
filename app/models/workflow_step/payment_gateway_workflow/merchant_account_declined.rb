class WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined < WorkflowStep::PaymentGatewayWorkflow::BaseStep
  def initialize(merchant_account_id, error_message=nil)
    @merchant_account = MerchantAccount.find_by_id(merchant_account_id)
    @error_message = error_message || @merchant_account.to_liquid.all_errors
  end

  # merchant_account
  #   MerchantAccount object
  # merchantable
  #   Company object
  # error_message
  #   String - combined error messages into one string, obtained from third party payment gateway

  def data
    { merchant_account: @merchant_account, merchantable: @merchant_account.merchantable, error_message: @error_message }
  end
end
