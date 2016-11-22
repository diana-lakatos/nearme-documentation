# frozen_string_literal: true
class InstanceAdmin::Manage::MerchantAccountsController < InstanceAdmin::Manage::BaseController
  skip_before_action :check_if_locked
  before_action :find_merchant_account, except: :index

  def index
    params[:mode] ||= PlatformContext.current.instance.test_mode ? PaymentGateway::TEST_MODE : PaymentGateway::LIVE_MODE

    @payment_gateways = PaymentGateway.payout_type.sort_by(&:name)
    merchant_account_scope = MerchantAccount.order('created_at DESC')
    merchant_account_scope = merchant_account_scope.where(state: params[:state]) if params[:state].present?
    merchant_account_scope = merchant_account_scope.where(payment_gateway_id: params[:payment_gateway_id]) if params[:payment_gateway_id].present?
    merchant_account_scope = merchant_account_scope.where(test: params[:mode] == PaymentGateway::TEST_MODE)

    @merchant_accounts = merchant_account_scope.paginate(per_page: 20, page: params[:page])
  end

  def void
    if @merchant_account.verified?
      if @merchant_account.void!
        flash[:success] = 'Merchant voided successfuly!'
      else
        flash[:warning] = 'This Merchant can not be voided.'
      end
    else
      flash[:warning] = 'This Merchant is not verified.'
    end
    redirect_to :back
  end

  def pending
    @merchant_account.to_pending!
    flash[:success] = 'Merchant is now pending changes!'
    redirect_to :back
  end

  private

  def find_merchant_account
    @merchant_account = MerchantAccount.find(params[:id])
    @merchant_account.skip_validation = true
  end
end
