class CheckoutController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_theme
  before_filter :set_order
  before_filter :build_payment_documents, only: [:show, :back]
  before_filter :set_countries_states, only: [:show, :update, :back]

  def show
    @order.try(:last_search_json=, cookies[:last_search])
    @order.object.try(:before_checkout_callback)

    event_tracker.reviewed_a_booking(@order)
  end

  def update
    @order.checkout_update = true
    if @order.update_attributes(order_params)
      if @order.payment && @order.payment.express_checkout_payment? && @order.payment.express_checkout_redirect_url
        redirect_to @order.payment.express_checkout_redirect_url
        return
      end

      flash[:notice] = ''  unless @order.inactive?
      flash[:error] = @order.errors.full_messages.join(',<br />')
    else
      set_countries_states
      flash[:error] = @order.errors.full_messages.join(',<br />')
    end

    if @order.inactive?
      render :show
    else
      event_tracker.updated_profile_information(@order.owner)
      event_tracker.updated_profile_information(@order.host)
      event_tracker.requested_a_booking(@order)

      card_message = @order.payment.credit_card_payment? ? t('flash_messages.reservations.credit_card_will_be_charged') : ''
      flash[:notice] = t('flash_messages.reservations.reservation_made', message: card_message)
      redirect_to dashboard_order_path(@order)
    end
  end

  def back
    @order.previous_step!
    render :show
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
    @order =  current_user.orders.find(params[:order_id]).try(:decorate)

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
        if !req.item.upload_obligation.not_required? && !requirement_ids.include?(req.id)
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
  end

  def order_params
    if params[:order] && !params[:order].blank?
      params.require(:order).permit(secured_params.order(@order.reservation_type))
    else
      {}
    end
  end
end
