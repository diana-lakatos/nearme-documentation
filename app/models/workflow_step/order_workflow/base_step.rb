class WorkflowStep::OrderWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(order_id)
    @order = Order.find_by(id: order_id)
    @lister = @order&.host
    @enquirer = @order&.owner
  end

  def workflow_type
    'order'
  end

  def transactable
    @order.transactables.first
  end

  def data
    {
      order: @order,
      enquirer: enquirer,
      lister: lister,
      listing: transactable,
      transactable: transactable
    }
  end

  def transactable_type_id
    transactable.try(:transactable_type_id)
  end

  def should_be_processed?
    @order.present?
  end
end
