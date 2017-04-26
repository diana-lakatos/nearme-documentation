# frozen_string_literal: true
class InstanceAdmin::Manage::OrderItemsController < InstanceAdmin::Manage::BaseController
  def edit
    order_item
  end

  def update
    order_item.update_attributes(secured_order_item_params)
    order.update_state!
    redirect_to action: :edit
  end

  private

  def secured_order_item_params
    params.require(:recurring_booking_period).permit([:paid_at])
  end

  def order_item
    @order_item ||= RecurringBookingPeriod.find(params[:id])
  end

  def order
    @order ||= order_item.order
  end
end
