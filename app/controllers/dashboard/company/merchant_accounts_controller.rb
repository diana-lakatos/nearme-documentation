# frozen_string_literal: true
class Dashboard::Company::MerchantAccountsController < Dashboard::Company::BaseController
  before_action :find_merchant_account, except: [:create]

  def update
    if @merchant_account.update_attributes(merchant_account_params)
      flash[:success] = t('flash_messages.manage.payouts.updated')
      redirect_to @merchant_account.try(:redirect_url) || edit_dashboard_company_payouts_path
    else
      render :edit
    end
  end

  def create
    @payment_gateway = all_payout_gateways.find(params[:payment_gateway_id])

    @merchant_account = MerchantAccount.new(merchantable: @company.object, type: @payment_gateway.merchant_account_type)
    @merchant_account.attributes = merchant_account_params
    @merchant_account.payment_gateway = @payment_gateway

    if @merchant_account.save
      redirect_to @merchant_account.try(:redirect_url) || edit_dashboard_company_payouts_path
    else
      @merchant_account.translate_error_messages
      @merchant_account.build_owners if @merchant_account.respond_to?(:owners)
      render :edit
    end
  end

  def all_payout_gateways
    if current_instance.skip_company?
      current_user.payout_payment_gateways
    else
      @company.payout_payment_gateways
    end
  end

  def boarding_complete
    @merchant_account.boarding_complete(params)
    flash[:notice] = params['returnMessage']
    redirect_to edit_dashboard_company_payouts_path
  end

  private

  def merchant_account_params
    if params[:merchant_account][:payment_subscription_attributes]
      params[:merchant_account][:payment_subscription_attributes][:payer_id] = current_user.id
    end
    params.require(:merchant_account).permit(secured_params.merchant_account(@merchant_account))
  end

  def find_merchant_account
    @merchant_account = @company.merchant_accounts.mode_scope.find(params[:id])
  end
end
