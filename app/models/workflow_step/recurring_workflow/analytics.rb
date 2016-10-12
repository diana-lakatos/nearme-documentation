class WorkflowStep::RecurringWorkflow::Analytics < WorkflowStep::RecurringWorkflow::BaseStep
  def initialize(company_id, user_id)
    @company = Company.find_by_id(company_id)
    @user = User.find_by_id(user_id)
  end

  def lister
    @user
  end

  def enquirer
    @user
  end

  def data
    { company: @company, user: @user, listing: @company.listings.first }
  end
end
