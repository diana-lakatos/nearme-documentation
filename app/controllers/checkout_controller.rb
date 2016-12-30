# frozen_string_literal: true
class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme
  before_action :set_order
  before_action :build_shipping_address, only: [:show, :update]
  before_action :build_payment_documents, only: [:show, :back]
  before_action :set_countries_states, only: [:show, :update, :back]
  before_action :blank_pricing_if_price_present_in_checkout, only: [:show]

  def show
    @order.try(:last_search_json=, cookies[:last_search])
    @order.object.try(:before_checkout_callback)
  end

  def update
    @order.checkout_update = true
    @order.attributes = order_params
    if @order.process!
      if @order.inactive?
        redirect_to @order.redirect_to_gateway || { action: :show }
      else
        card_message = @order.payment.credit_card_payment? ? t('flash_messages.reservations.credit_card_will_be_charged') : ''
        flash[:notice] = t('flash_messages.reservations.reservation_made', message: card_message)
        redirect_to dashboard_order_path(@order)
      end
    else
      flash.now[:error] = @order.errors.full_messages.join(',<br />')
      render(:show)
    end
  end

  def back
    @order.previous_step!
    redirect_to action: :show
  end

  def get_states
    @states = State.where(country_id: params[:country_id])
  end

  private

  def set_theme
    @theme_name = 'buy-sell-theme'
  end

  def set_countries_states
    @countries = Country.order('name')
    @billing_states = billing_states
    @shipping_states = shipping_states
  end

  def billing_states
    @order.billing_address.try(:country) ? State.where(country: @order.shipping_address.try(:country)) : []
  end

  def shipping_states
    @order.shipping_address.try(:country) ? State.where(country: @order.shipping_address.try(:country)) : []
  end

  def set_order
    @order = current_user.orders.cart.find(params[:order_id]).try(:decorate)

    if @order.blank?
      flash[:error] = t('buy_sell_market.checkout.order_missing')
      redirect_to cart_index_path
    end
  end

  def build_payment_documents
    @order.transactables.each do |transactable|
      if transactable.document_requirements.blank? &&
         PlatformContext.current.instance.force_file_upload?
        transactable.document_requirements.create(label: I18n.t('upload_documents.file.default.label'),
                                                  description: I18n.t('upload_documents.file.default.description'))
      end

      requirement_ids = @order.payment_documents.map do |pd|
        pd.payment_document_info.document_requirement_id
      end + transactable.document_requirements.map(&:id)

      if transactable.upload_obligation.blank? &&
         PlatformContext.current.instance.documents_upload_enabled?
        transactable.create_upload_obligation(level: UploadObligation.default_level)
      end

      transactable.document_requirements.each do |req|
        next unless !req.item.upload_obligation.not_required? && !requirement_ids.include?(req.id)
        @order.payment_documents.build(
          attachable: @order,
          user: @user,
          payment_document_info_attributes: {
            document_requirement: req
          }
        )
      end
    end
  end

  def order_params
    if params[:order] && !params[:order].blank?
      params.require(:order).permit(secured_params.order(@order.reservation_type))
    else
      {}
    end
  end

  def build_shipping_address
    return unless Shippings.enabled?(@order)

    # FIX this should be generic validation
    @order.add_validator Deliveries::Sendle::Validations::Order.new
    @order.shipping_address = Deliveries::ShippingAddressBuilder.build(@order, @order.user)
  end

  # We want the price by default to be nil if the pricing select is in the form
  def blank_pricing_if_price_present_in_checkout
    @order.reservation_type.form_components.each do |form_component|
      form_component.form_fields.each do |field|
        if field == { 'reservation' => 'price' }
          @order.transactable_pricing_id = nil
          return true
        end
      end
    end

    true
  end
end
