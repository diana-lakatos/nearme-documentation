class BuySellMarket::CheckoutController < ApplicationController
  include Wicked::Wizard
  include Spree::Core::ControllerHelpers::StrongParameters

  CHECKOUT_STEPS = [:address, :delivery, :payment, :complete]
  steps *CHECKOUT_STEPS

  before_filter :set_order
  before_filter :check_step
  before_filter :set_state, only: [:show]

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

    if params[:id] == 'payment'
      @billing_gateway = Billing::Gateway::Incoming.new(current_user, PlatformContext.current.instance, @order.currency)

      if @order.billing_authorization.nil?
        @order.card_expires = params[:order][:card_expires].try(:to_s).try(:strip)
        @order.card_number = params[:order][:card_number].try(:to_s).try(:strip)
        @order.card_code = params[:order][:card_code].try(:to_s).try(:strip)
        credit_card = ActiveMerchant::Billing::CreditCard.new(
          first_name: params[:first_name].presence || current_user.first_name,
          last_name: params[:last_name].presence || current_user.last_name,
          number: @order.card_number,
          month: @order.card_expires.to_s[0,2],
          year: @order.card_expires.to_s[-4,4],
          verification_value: @order.card_code
        )
        if credit_card.valid?
          response = @billing_gateway.authorize(@order.total_amount_to_charge, credit_card)
          if response[:error].present?
            @order.errors.add(:cc, response[:error])
            p = @order.payments.build(amount: @order.total_amount_to_charge, company_id: @order.company_id)
            p.failure!
            render_step order_state and return
          else
            @order.create_billing_authorization(
              token: response[:token],
              payment_gateway_class: response[:payment_gateway_class],
              payment_gateway_mode: PlatformContext.current.instance.test_mode? ? "test" : "live"
            )
          end
          p = @order.payments.build(amount: @order.total_amount_to_charge, company_id: @order.company_id)
          p.pend!
          unless @order.next
            flash[:error] = spree_errors
            render_step order_state and return
          end
          charge = @order.near_me_payments.create!(
            subtotal_amount: @order.total_amount_without_fee,
            service_fee_amount_guest: @order.service_fee_amount_guest,
            service_fee_amount_host: @order.service_fee_amount_host
          )
          if charge.paid?
            p.complete!
          else
            p.failure!
          end
        else
          @order.errors.add(:cc, "Those credit card details don't look valid")
          render_step order_state and return
        end
      end
      if @order.errors.any?
        flash[:error] = spree_errors
        render_step order_state and return
      else
      end
    elsif params[:id] == 'confirmation'
      if @order.billing_authorization.try(:token).present?
      end
    elsif  @order.update_from_params(params, permitted_checkout_attributes)

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
    return true if step == :address

    if CHECKOUT_STEPS.index(step) > CHECKOUT_STEPS.index(order_state)
      @order.restart_checkout_flow
      flash[:error] = 'You are not allowed here'
      redirect_to cart_index_path
    end
  end

  def set_state
    @order.update_columns(state: step.to_s, updated_at: Time.zone.now)
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
