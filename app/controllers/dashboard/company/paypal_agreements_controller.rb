class Dashboard::Company::PaypalAgreementsController < Dashboard::Company::BaseController
  before_action :get_payment_gateway_data
  before_action :get_merchant_account

  def new
    @payment_gateway.set_billing_agreement({
      ip: request.remote_ip,
      return_url: dashboard_company_paypal_agreement_create_url(@merchant_account.id, host: request.host_with_port),
      cancel_return_url: redirect_url
    })

    redirect_to @payment_gateway.redirect_url
  end

  def create
    if @merchant_account.create_billing_agreement(params[:token])
      flash[:success] = 'Permission granted!'
    else
      flash[:error] = 'Permission can\'t be granted!'
    end
    redirect_to redirect_url
  end

  def destroy
    if @merchant_account.destroy_billing_agreement
      flash[:success] = 'Permission revoked!'
    else
      flash[:error] = 'Permission can\'t be revoked!'
    end
    redirect_to redirect_url
  end

  private

  def get_payment_gateway_data
    @payment_gateway = @company.payout_payment_gateway
    redirect_to redirect_url if @payment_gateway.blank? || !@payment_gateway.supports_paypal_chain_payments?
  end

  def get_merchant_account
    @merchant_account = @company.send("paypal_express_chain_merchant_account")
    redirect_to redirect_url if @merchant_account.blank?
  end

  def redirect_url
    edit_dashboard_company_payouts_url(host: request.host_with_port)
  end
end
