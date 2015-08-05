Spree::Shipment.class_eval do
  include Spree::Scoper

  def to_liquid
    @spree_shipment_drop ||= Spree::ShipmentDrop.new(self)
  end

  private

  def send_shipped_email
    WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Shipped, id)
  end

end

