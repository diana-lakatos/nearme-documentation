class WorkflowStep::PayoutWorkflow::NoPayoutOption < WorkflowStep::PayoutWorkflow::BaseStep
  def initialize(company_id, created_payment_transfers)
    super(company_id)
    @company.created_payment_transfers = created_payment_transfers
  end
end
