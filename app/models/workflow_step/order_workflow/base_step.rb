class WorkflowStep::OrderWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(order_id)
    @order = Spree::Order.find_by_id(order_id)
  end

  def workflow_type
    'order'
  end

  def enquirer
    @order.user
  end

  def lister
    @order.company.creator
  end

  def data
    { order: @order }
  end

end

