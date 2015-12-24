class BuySellMarket::CheckoutController < ApplicationController
  include Wicked::Wizard
  include Spree::Core::ControllerHelpers::StrongParameters


  CHECKOUT_STEPS = [:address, :delivery, :payment, :complete]
  steps *CHECKOUT_STEPS

  skip_before_filter :log_out_if_token_exists
  skip_before_filter :filter_out_token

  before_filter :authenticate_user!
  before_filter :set_theme
  before_filter :set_order
  before_filter :check_step, only: [:show, :update]
  before_filter :set_state, only: [:show]
  before_filter :check_qty_on_step, only: [:show, :update]
  before_filter :assign_order_attributes, only: [:update]
  before_filter :set_payment_methods, only: [:show, :update]
  before_filter :set_countries_states, only: [:show, :update]

  def show
    case step
    when :address
      @order.reload.restart_checkout_flow
    when :delivery
      packages = @order.shipments.map { |s| s.to_package }
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
    when :payment
      build_approval_request_for_object(current_user)
      checkout_service.build_payment_documents
      @order.express_token = params[:token] if params[:token].present?
    when :complete
      @current_order = nil
      flash[:success] = t('buy_sell_market.checkout.notices.order_placed')
      redirect_to success_dashboard_order_path(params[:order_id])
      return
    end

    render_wizard
  end

  def update
    if @order.payable?
      checkout_extra_fields = @order.checkout_extra_fields(params[:order][:checkout_extra_fields])
      checkout_extra_fields.assign_attributes! if checkout_extra_fields.are_fields_present?

      if checkout_extra_fields.valid?
        checkout_extra_fields.save! if checkout_extra_fields.are_fields_present?
      else
        checkout_extra_fields.errors.full_messages.each { |m| @order.errors[:checkout_fields] ||= []; @order.errors[:checkout_fields] << m }
        render_step order_state and return
      end

      checkout_service.update_payment_documents
      @order.payment_method.payment_gateway.authorize(@order)
    elsif @order.save && @order.address?
      save_user_addresses
      update_blank_user_fields
    end

    if @order.payment_method.try(:express_checkout?) && @order.express_checkout_redirect_url.present? && @order.save
      redirect_to @order.express_checkout_redirect_url
    else
      # We don't want to override validation messages by calling next
      jump_to next_step if spree_errors.blank? && @order.valid? && (@order.complete? || @order.next)

      flash.now[:error] = spree_errors if spree_errors.present?
      render_wizard
    end
  end

  def get_states
    @states = Spree::State.where(country_id: params[:country_id])
  end

  def cancel_express_checkout
    @order.update_attribute(:express_token, nil)
    flash[:notice] = I18n.t('flash_messages.buy_sell_market.checkout.cancel_paypal_express')
    jump_to :payment
    render_wizard
  end

  private

  def assign_order_attributes
    @order.assign_attributes(spree_order_params)
  end

  def set_theme
    @theme_name = 'buy-sell-theme'
    @render_content_outside_container = true
  end

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

  def update_blank_user_fields
    BuySell::UpdateBlankUserFieldsService.new(current_user).update_blank_user_fields(@order.bill_address)
  end

  def check_step
    return true if step == :address

    if CHECKOUT_STEPS.index(step) > CHECKOUT_STEPS.index(order_state)
      @order.try(:restart_checkout_flow)
      flash[:error] = t('buy_sell_market.checkout.errors.skip')
      redirect_to cart_index_path
      return
    end
  end

  def set_state
    @order.try(:update_columns, {state: step.to_s, updated_at: Time.zone.now})
  end

  def set_countries_states
    if step == :address
      @countries = Spree::Country.order('name')
      @billing_states = billing_states
      @shipping_states = shipping_states
    end
  end

  def billing_states
    @order.bill_address.nil? ? [] : Spree::State.where(country_id: @order.bill_address.country_id)
  end

  def shipping_states
    @order.ship_address.nil? ? [] : Spree::State.where(country_id: @order.ship_address.country_id)
  end

  def set_order
    @order ||= if (step == :complete)
      current_user.orders.find_by(number: params[:order_id])
    else
      current_user.cart_orders.find_by(number: params[:order_id]).try(:decorate)
    end

    if @order.blank?
      flash[:error] = t('buy_sell_market.checkout.order_missing')
      redirect_to cart_index_path
    end
  end

  def spree_errors
    @order.errors.full_messages.join("\n") if @order.errors.present?
  end

  def order_state
    @order.state.to_sym
  end

  def set_payment_methods
    payment_gateways = current_instance.payment_gateways(@order.company.iso_country_code, @order.currency)

    if payment_gateways.blank?
      flash[:error] = t('flash_messages.buy_sell.no_payment_gateway')
      redirect_to(cart_index_path)
    else
      @payment_methods = payment_gateways.map(&:active_payment_methods).flatten
    end
  end

  def checkout_service
    @checkout_service ||= BuySell::CheckoutService.new(current_user, @order, params)
  end

  def spree_order_params
    params[:order] ||= {}
    params[:order][:payment_method_nonce] = params[:payment_method_nonce] if params[:payment_method_nonce]
    params.require(:order).permit(secured_params.spree_order + permitted_checkout_attributes)
  end
end

