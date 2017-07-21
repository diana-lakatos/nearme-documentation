class WorkflowStep::OrderItemWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(order_item_id)
    @order_item = RecurringBookingPeriod.find_by(id: order_item_id)
  end

  def workflow_type
    'order_item'
  end

  def lister
    @order_item.creator
  end

  def enquirer
    @order_item.owner
  end

  # order_item:
  #   OrderItem object
  # enquirer:
  #   listing User object
  # lister:
  #   enquiring User object
  # transactable:
  #   Transactable object
  def data
    { order_item: @order_item, enquirer: enquirer, lister: lister, transactable: @order_item.transactable }
  end

  def transactable_type_id
    @order_item.transactable.transactable_type_id
  end
end
