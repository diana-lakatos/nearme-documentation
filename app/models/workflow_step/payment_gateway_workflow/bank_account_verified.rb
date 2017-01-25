class WorkflowStep::PaymentGatewayWorkflow::BankAccountVerified < WorkflowStep::PaymentGatewayWorkflow::BaseStep
  def initialize(bank_account_id)
    @bank_account = BankAccount.find_by_id(bank_account_id)
  end

  def enquirer
    @bank_account.instance_client.client
  end

  # bank_account
  #   BankAccount object
  # enquirer
  #   User object
  def data
    { bank_account: @bank_account, enquirer: enquirer }
  end
end
