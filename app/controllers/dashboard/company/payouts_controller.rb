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
      redirect_to @merchant_account.try(:redirect_url) || {action: :edit}
    else
      render :edit
    end
  end

  def boarding_complete
    @merchant_account = @company.send("#{@payment_gateway_type}_merchant_account")
    @merchant_account.boarding_complete(params)
    flash[:notice] = params["returnMessage"]
    redirect_to action: :edit
  end

  private

  def company_params
    params.require(:company).permit(secured_params.company)
  end

  def get_payment_gateway_data
    if current_instance.skip_company?
      @payment_gateway = current_user.payout_payment_gateway
    else
      @payment_gateway = @company.payout_payment_gateway
    end
    if @payment_gateway.present?
      @payment_gateway_type = @payment_gateway.type_name
      @merchant_account_form_path = "dashboard/company/merchant_accounts/#{@payment_gateway_type}"
    end
  end

  def build_merchant_account
    if @payment_gateway.present?
      @merchant_account = @company.send("#{@payment_gateway_type}_merchant_account") \
        || @company.send("build_#{@payment_gateway_type}_merchant_account", payment_gateway_id: @payment_gateway.id)

      if @payment_gateway.supports_host_subscription? && @merchant_account.payment_subscription.blank?
        @merchant_account.build_payment_subscription(
          payer: current_user,
          subscriber: @merchant_account,
          payment_method_id: @payment_gateway.payment_methods.credit_card.first.id
        )
      end
    end
  end
end

