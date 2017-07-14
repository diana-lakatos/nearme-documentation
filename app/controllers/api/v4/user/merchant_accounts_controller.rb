# frozen_string_literal: true
module Api
  class V4::User::MerchantAccountsController < Api::V4::User::BaseController
    before_filter :redirect_unless_registration_completed

    def create
      merchant_account_form.validate(form_params) && merchant_account_form.save
      respond(merchant_account_form)
    end

    protected

    def merchant_account_form
      @merchant_account_form ||= form_configuration.build(merchant_account)
    end

    def merchant_account
      @merchant_account = MerchantAccount.new(
        merchantable: company,
        type: payment_gateway.merchant_account_type,
        payment_gateway: payment_gateway
      )
    end

    def form_params
      params[:merchant_account].presence || {}
    end

    def payment_gateway
      @payment_gateway ||= PaymentGateway.with_credit_card.mode_scope.first
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
