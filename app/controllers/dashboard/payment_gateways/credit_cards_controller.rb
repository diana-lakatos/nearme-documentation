class Dashboard::PaymentGateways::CreditCardsController < Dashboard::BaseController
  before_filter :find_payment_gateways
  before_filter :find_payment_gateway
  before_filter :find_instance_client
  before_filter :find_credit_card, only: [:destroy]

  def index
    @credit_cards = @instance_client.credit_cards
  end

  def new
    @credit_card = @instance_client.credit_cards.build(payment_gateway: @payment_gateway)
  end

  def create
    @credit_card = @instance_client.credit_cards.build(credit_card_params)
    @credit_card.payment_method = @payment_gateway.payment_methods.credit_card.last
    if @credit_card.process! && @credit_card.save
      flash[:success] = t('flash_messages.manage.credit_cards.added')
      redirect_to dashboard_payment_gateway_credit_cards_path(@payment_gateway)
    else
      flash.now[:error] = t('flash_messages.manage.credit_cards.not_added')
      render :new
    end
  end

  def destroy
    @credit_card.destroy
    flash[:deleted] = t('flash_messages.manage.credit_cards.deleted')
    redirect_to dashboard_payment_gateway_credit_cards_path(@payment_gateway)
  end

  private

  def find_payment_gateways
    @payment_gateways = PaymentGateway.with_credit_card.mode_scope
  end

  def find_payment_gateway
    @payment_gateway = @payment_gateways.find(params[:payment_gateway_id])
  end

  def find_instance_client
    @instance_client = current_user.instance_clients.for_payment_gateway(@payment_gateway.id, current_instance.test_mode?).first
    if @instance_client.nil?
      flash[:deleted] = t('flash_messages.manage.credit_cards.not_configured')
      redirect_to request.referer.presence || root_path
    end
  end

  def find_credit_card
    @credit_card = @instance_client.credit_cards.find(params[:id])
  end

  def credit_card_params
    params.require(:credit_card).permit(secured_params.credit_card)
  end
end
