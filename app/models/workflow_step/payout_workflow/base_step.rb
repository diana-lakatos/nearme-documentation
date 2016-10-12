class WorkflowStep::PayoutWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(company_id)
    @company = Company.find_by_id(company_id)
  end

  def workflow_type
    'payout'
  end

  def enquirer
    nil
  end

  def lister
    @company.creator
  end

  # company:
  #   Company object
  def data
    { company: @company }
  end
end
