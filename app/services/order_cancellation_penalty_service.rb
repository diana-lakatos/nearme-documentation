# frozen_string_literal: true
class OrderCancellationPenaltyService
  attr_reader :order, :payment

  def initialize(order)
    @order = order
    @payment = order.payment
  end

  def charge!
    if order.penalty_charge_apply? 
      raise('Charging penalty when there exist already authorized/paid payment!') if payment.present? && (payment.paid? || payment.authorized?)
      order.line_items.where.not(id: order.transactable_line_item.id).destroy_all
      order.transactable_line_item.update_columns(unit_price_cents: order.penalty_amount_cents, quantity: 1, name: 'Cancellation Penalty')
      order.reload
      order.transactable_line_item.build_service_fee.try(:save!)
      order.transactable_line_item.build_host_fee.try(:save!)
      order.update_payment_attributes
      order.payment.payment_transfer.try(:send, :assign_amounts_and_currency)

      if order.payment.authorize! && order.payment.capture!
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PenaltyChargeSucceeded, order.id)
      else
        WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::PenaltyChargeFailed, order.id)
      end
    end
    true
  end
end
