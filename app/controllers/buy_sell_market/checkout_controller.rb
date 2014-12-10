class BuySellMarket::CheckoutController < ApplicationController
  include Wicked::Wizard
  include Spree::Core::ControllerHelpers::StrongParameters

  before_filter :authenticate_user!

  CHECKOUT_STEPS = [:address, :delivery, :payment, :complete]
  steps *CHECKOUT_STEPS

  before_filter :set_order
  before_filter :check_step, except: [:get_states]
  before_filter :set_state, only: [:show]
  before_filter :check_qty_on_step, only: [:show, :update]

  def show
    # Temporary solution for blocking checkout process if we do not support any PaymentGateway
    # we should decide what TODO with users from not supported countries
    if Billing::Gateway::Incoming.new(current_user, PlatformContext.current.instance, @order.currency).processor.nil?
      flash[:error] = "Payment is not supported for this country"
      redirect_to cart_index_path and return
    end

    case step
    when :address
      @order.restart_checkout_flow
      @order.use_billing = 0
      set_countries_states
    when :delivery
      packages = @order.shipments.map { |s| s.to_package }
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
    when :complete
      flash[:notice] = t('buy_sell_market.checkout.notices.order_placed')

      begin
        @charge_info = @order.near_me_payments.paid.first.charge_attempts.successful.first
      rescue
        @charge_info = nil
      end
    end

    render_wizard
  end

  def update
    if step == :address
      set_countries_states
    end

    if @order.payment?
      @billing_gateway = Billing::Gateway::Incoming.new(current_user, PlatformContext.current.instance, @order.currency)
      @order.card_expires = params[:order][:card_expires].try(:to_s).try(:strip)
      @order.card_number = params[:order][:card_number].try(:to_s).try(:strip)
      @order.card_code = params[:order][:card_code].try(:to_s).try(:strip)
      credit_card = ActiveMerchant::Billing::CreditCard.new(
          first_name: params[:first_name].presence || current_user.first_name,
          last_name: params[:last_name].presence || current_user.last_name,
          number: @order.card_number,
          month: @order.card_expires.to_s[0, 2],
          year: @order.card_expires.to_s[-4, 4],
          verification_value: @order.card_code
      )
      if credit_card.valid?
        response = @billing_gateway.authorize(@order.total_amount_to_charge, credit_card)
        if response[:error].present?
          @order.errors.add(:cc, response[:error])
          p = @order.payments.build(amount: @order.total_amount_to_charge, company_id: @order.company_id)
          p.started_processing
          p.failure!
          render_step order_state and return
        else
          @order.create_billing_authorization(
              token: response[:token],
              payment_gateway_class: response[:payment_gateway_class],
              payment_gateway_mode: PlatformContext.current.instance.test_mode? ? "test" : "live"
          )
          p = @order.payments.build(amount: @order.total_amount_to_charge, company_id: @order.company_id)
          p.pend!
          unless @order.next
            flash[:error] = spree_errors
            render_step order_state and return
          end
        end
      else
        @order.errors.add(:cc, "Those credit card details don't look valid")
        render_step order_state and return
      end
    elsif @order.update_from_params(params, permitted_checkout_attributes)

      if step == :address
        save_user_addresses if params[:order][:save_billing_address]
        set_countries_states
      end

      unless @order.next
        flash[:error] = spree_errors
        render_step order_state and return
      end

      if @order.completed?
        @current_order = nil
        render_step :complete and return # TODO Refactor to redirect
      end
    else
      render_step order_state and return
    end

    jump_to next_step
    render_wizard
  end

  def get_states
    @states = Spree::State.where(country_id: params[:country_id])
  end

  private

  def check_qty_on_step
    return true if step == :complete

    qty_check_serivce = BuySell::OrderQtyCheckService.new(@order)
    unless qty_check_serivce.check
      flash[:error] = t('buy_sell_market.checkout.errors.qty', items: qty_check_serivce.items_out_of_stock)
      redirect_to cart_index_path
    end
  end

  def save_user_addresses
    BuySell::SaveUserAddressesService.new(current_user).save_addresses(@order.bill_address, @order.ship_address)
  end

  def check_step
    return true if step == :address

    if CHECKOUT_STEPS.index(step) > CHECKOUT_STEPS.index(order_state)
      @order.restart_checkout_flow
      flash[:error] = t('buy_sell_market.checkout.errors.skip')
      redirect_to cart_index_path
    end
  end

  def set_state
    @order.update_columns(state: step.to_s, updated_at: Time.zone.now)
  end

  def set_countries_states
    @countries = Spree::Country.order('name')
    @billing_states = billing_states
    @shipping_states = shipping_states
  end

  def billing_states
    @order.bill_address.nil? ? [] : Spree::State.where(country_id: @order.bill_address.country_id)
  end

  def shipping_states
    @order.ship_address.nil? ? [] : Spree::State.where(country_id: @order.ship_address.country_id)
  end

  def set_order
    @order ||= if step == :complete
                 current_user.orders.find_by(number: params[:order_id])
               else
                 current_user.cart_orders.find_by(number: params[:order_id]).try(:decorate)
               end
  end

  def spree_errors
    @order.errors.full_messages.join("\n")
  end

  def order_state
    @order.state.to_sym
  end
end
