# frozen_string_literal: true
class Dashboard::Company::PaymentSubscriptionsController < Dashboard::BaseController
  before_action :find_order
  before_action :find_countries
  before_action :find_payment_subscription, except: [:new, :create]
  before_action :find_payment_gateway_data
  before_action :build_payment_subscription, only: [:new, :create]

  def new
    @redirect_to = dashboard_company_transactable_type_transactables_path(@order.transactable.transactable_type, status: 'in progress')
    render layout: false
  end

  def create
    @payment_subscription.attributes = payment_subscription_params
    @redirect_to = dashboard_company_transactable_type_transactables_path(@order.transactable.transactable_type, status: 'in progress')

    if @payment_subscription.process! && @payment_subscription.save! && @order.charge_and_confirm!
      flash[:notice] = I18n.t('flash_messages.dashboard.offer.accepted')
      handle_redirect(@redirect_to)
    else
      render_form
    end
  end

  def edit
    @redirect_to = dashboard_company_order_order_items_path(@order, transactable_id: @order.transactable.id)
    render :new, layout: false
  end

  def update
    @redirect_to = dashboard_company_order_order_items_path(@order, transactable_id: @order.transactable.id)
    @payment_subscription.attributes = payment_subscription_params
    if @payment_subscription.process! && @payment_subscription.save!
      flash[:notice] = t('flash_messages.dashboard.payment_subscription.updated')
      handle_redirect(@redirect_to)
    else
      render_form
    end
  end

  private

  def build_payment_subscription
    @payment_subscription = @order.payment_subscription || @order.build_payment_subscription(
      payer: current_user.object,
      company: @order.owner.default_company
    ).decorate
  end

  def find_payment_gateway_data
    @payment_gateways = payment_gateway_data
  end

  def payment_gateway_data
    if current_instance.skip_company?
      current_user.payout_payment_gateways
    else
      @order.company.payout_payment_gateways
    end
  end

  def payment_subscription_params
    params.require(:payment_subscription).permit(secured_params.payment_subscription)
  end

  def find_order
    @order = @company.orders.find(params[:order_id])
  end

  def find_countries
    @countries = Country.order('name')
  end

  def find_payment_subscription
    @payment_subscription = @order.payment_subscription.decorate
  end

  def handle_redirect(redirect_url)
    redirect_to redirect_url
    render_redirect_url_as_json if request.xhr?
  end

  def render_form
    render partial: 'form', layout: false
  end
end
