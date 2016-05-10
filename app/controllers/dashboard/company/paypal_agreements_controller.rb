class Dashboard::Company::PaypalAgreementsController < Dashboard::Company::BaseController
  before_action :get_merchant_account

  def new
    response = @payment_gateway.set_billing_agreement({
      ip: request.remote_ip,
      return_url: dashboard_company_merchant_account_paypal_agreements_url(@merchant_account.id, host: request.host_with_port),
      cancel_return_url: redirect_url
    })

    if response.success?
      redirect_to @payment_gateway.redirect_url
    else
      flash[:error] = response.params["Errors"]["LongMessage"] + ". Error Code: #{response.params["Errors"]["ErrorCode"]}"
      redirect_to redirect_url
    end
  end

  def index
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

  def get_merchant_account
    @merchant_account = @company.merchant_accounts.find(params[:merchant_account_id])
    @payment_gateway = @merchant_account.payment_gateway
    if @payment_gateway.blank? || !@payment_gateway.active_in_current_mode? || !@payment_gateway.supports_paypal_chain_payments?
      redirect_to redirect_url
    end
  end

  def redirect_url
    edit_dashboard_company_payouts_url(host: request.host_with_port)
  end
end
