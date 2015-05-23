class WorkflowStep::OrderWorkflow::Shipped < WorkflowStep::OrderWorkflow::BaseStep

  def initialize(shipment_id)
    @shipment = Spree::Shipment.find_by_id(shipment_id)
    @order = @shipment.order
  end

  # shipment:
  #   Spree::Shipment object
  # order:
  #   Spree::Order object
  def data
    { shipment: @shipment, order: @order }
  end
end

