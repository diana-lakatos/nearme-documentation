class BuySellMarket::CheckoutController < ApplicationController
  include Wicked::Wizard
  include Spree::Core::ControllerHelpers::StrongParameters

  # TODO Check for skipping steps by entering address
  steps :address, :delivery, :payment, :confirm, :complete

  before_filter :set_order
  before_filter :check_step

  def show
    case step
      when :address
        @order.restart_checkout_flow
        @order.use_billing = 1
    end

    render_wizard
  end

  # TODO Refactor to service object
  def update
    if  @order.update_from_params(params, permitted_checkout_attributes)

      save_user_addresses if step == :address && params[:order][:save_billing_address]

      unless @order.next
        flash[:error] = spree_errors
        render_step order_state and return
      end

      if @order.completed?
        @current_order = nil
        flash.notice = Spree.t(:order_processed_successfully) # TODO
        flash['order_completed'] = true
        render_step :complete and return # TODO Refactor to redirect
      end

    else
      flash[:error] = spree_errors
      render_step order_state and return
    end

    jump_to next_step
    render_wizard
  end

  private

  def save_user_addresses
    BuySell::SaveUserAddressesService.new(current_user).save_addresses(@order.bill_address, @order.ship_address)
  end

  def check_step
    # TODO
  end

  def set_order
    @order ||= current_user.cart_orders.find_by(number: params[:order_id]).decorate
  end

  def spree_errors
    @order.errors.full_messages.join("\n")
  end

  def order_state
    @order.state.to_sym
  end
end
