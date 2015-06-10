class WorkflowStep::LineItemWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(line_item_id)
    @line_item = Spree::LineItem.find_by_id(line_item_id)
  end

  def workflow_type
    'line_item'
  end

  def lister
    @line_item.product.administrator
  end

  def enquirer
    @line_item.order.user
  end

  # line_item:
  #   LineItem object
  # user:
  #   User object
  # host:
  #   enquiring User object
  def data
    { line_item: @line_item, user: lister, host: enquirer }
  end
end
