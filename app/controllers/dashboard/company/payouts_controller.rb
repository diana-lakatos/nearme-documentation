class Dashboard::Company::PayoutsController < Dashboard::Company::BaseController

  before_action :get_payment_gateway_data
  before_action :build_merchant_account

  def edit
    @merchant_account.try(:initialize_defaults) if @merchant_account.try(:new_record?)
    @merchant_account.owners.build if @merchant_account.respond_to?(:owners) && !@merchant_account.owners.present?
  end

  def update
    if @company.update_attributes(company_params)
      flash[:success] = t('flash_messages.manage.payouts.updated')
      redirect_to action: :edit
    else
      @merchant_account = @company.send("#{@payment_gateway_type}_merchant_account")
      render :edit
    end
  end

  private

  def company_params
    params.require(:company).permit(secured_params.company)
  end

  def get_payment_gateway_data
    @payment_gateway = @company.payout_payment_gateway
    if @payment_gateway.present?
      @payment_gateway_type = @payment_gateway.type.gsub('PaymentGateway', '').sub('::', '').underscore.tr(' ', '_')
      @merchant_account_form_path = "dashboard/company/merchant_accounts/#{@payment_gateway_type}"
    end
  end

  def build_merchant_account
    if @payment_gateway.present?
      @merchant_account = @company.send("#{@payment_gateway_type}_merchant_account") \
        || @company.send("build_#{@payment_gateway_type}_merchant_account", payment_gateway_id: @payment_gateway.id)
    end
  end

end

