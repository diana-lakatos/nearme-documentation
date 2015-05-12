class Dashboard::Company::PayoutsController < Dashboard::Company::BaseController
  before_action :build_merchant_account

  def edit
  end

  def update
    params[:merchant_account] ||= {}
    @company.assign_attributes(company_params)
    @merchant_account.try(:update_data, params[:merchant_account][:data])
    if @company.save && (@merchant_account.nil? || @merchant_account.save)
      flash[:success] = t('flash_messages.manage.payouts.updated')
      redirect_to action: :edit
    else
      render :edit
    end
  end

  private

  def company_params
    params.require(:company).permit(secured_params.company)
  end

  def build_merchant_account
    @payment_gateway = platform_context.instance.payment_gateway(@company.iso_country_code, @company.locations.first.try(:listings).try(:first).try(:currency).presence || 'USD')
    if @payment_gateway.try(:supports_payout?)
      @merchant_account_form_path = "dashboard/company/merchant_accounts/#{@payment_gateway.type.gsub('PaymentGateway', '').sub('::', '').underscore.tr(' ', '_')}"
      @merchant_account = @payment_gateway.merchant_accounts.where(merchantable_id: @company.id, merchantable_type: 'Company').first
      if @merchant_account.nil?
        @merchant_account = case @payment_gateway
                            when PaymentGateway::BraintreeMarketplacePaymentGateway
                              MerchantAccount::BraintreeMarketplaceMerchantAccount
                            when PaymentGateway::PaypalPaymentGateway
                              MerchantAccount::PaypalMerchantAccount
                            end.try(:new, merchantable_id: @company.id, merchantable_type: 'Company', payment_gateway: @payment_gateway)
      end
    end
  end

end

