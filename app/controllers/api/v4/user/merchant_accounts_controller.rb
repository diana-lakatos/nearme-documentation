# frozen_string_literal: true
module Api
  class V4::User::MerchantAccountsController < Api::V4::User::BaseController
    before_filter :redirect_unless_registration_completed

    def create
      SubmitForm.new(
        form_configuration: form_configuration,
        form: merchant_account_form,
        params: form_params,
        current_user: current_user
      ).call
      respond(merchant_account_form)
    end

    def update
      SubmitForm.new(
        form_configuration: form_configuration,
        form: merchant_account_update_form,
        params: form_params,
        current_user: current_user
      ).call
      respond(merchant_account_update_form)
    end

    protected

    def merchant_account_form
      @merchant_account_form ||= form_configuration.build(new_merchant_account)
    end

    def merchant_account_update_form
      @merchant_account_update_form ||= form_configuration.build(merchant_account)
    end

    def new_merchant_account
      MerchantAccount.new(
        merchantable: company,
        type: payment_gateway.merchant_account_type,
        payment_gateway: payment_gateway
      )
    end

    def merchant_account
      company.merchant_accounts.mode_scope.find(params[:id])
    end

    def form_params
      params[:merchant_account].presence || {}
    end

    def payment_gateway
      @payment_gateway ||= PaymentGateway.with_credit_card.mode_scope.first!
    rescue ActiveRecord::RecordNotFound
      raise PaymentGateway::NoPaymentGatewayForCredirCards, 'No PaymentGateway configured for credit card. Please add one.'
    end

    def company
      current_user.default_company
    end

    def redirect_unless_registration_completed
      unless current_user.registration_completed?
        flash[:warning] = t('flash_messages.dashboard.add_your_company')
        redirect_to root_path
      end
    end
  end
end
