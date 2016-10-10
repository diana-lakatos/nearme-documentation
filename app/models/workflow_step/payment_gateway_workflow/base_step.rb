class WorkflowStep::PaymentGatewayWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(merchant_account_id)
    @merchant_account = MerchantAccount.find_by_id(merchant_account_id)
  end

  def workflow_type
    'payment_gateway'
  end

  def lister
    @merchant_account.merchantable.creator
  end

  # merchant_account
  #   MerchantAccount object
  # merchantable
  #   Company object
  def data
    { merchant_account: @merchant_account, merchantable: @merchant_account.merchantable }
  end
end
