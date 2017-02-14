class WorkflowStep::PayoutWorkflow::NoPayoutOption < WorkflowStep::PayoutWorkflow::BaseStep
  def initialize(company_id, created_payment_transfers_ids)
    super(company_id)
    @created_payment_transfers = PaymentTransfer.where(id: created_payment_transfers_ids)
  end

  def data
    # We need to set it in data otherwise the accessor set variables get lost
    # when executed through delayed jobs
    @company.created_payment_transfers = @created_payment_transfers

    { company: @company }
  end
end
