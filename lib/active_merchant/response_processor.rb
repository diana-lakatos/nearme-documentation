# frozen_string_literal: true
module ActiveMerchant
  class ResponseProcessor
    attr_reader :response, :payment_gateway, :merchant_account

    delegate :authorization, :success?, :message, to: :response

    def initialize(response, payment_gateway, merchant_account = nil)
      @response = response
      @payment_gateway = payment_gateway
      @merchant_account = merchant_account
    end

    def payment_attributes
      {
        external_id: authorization,
        charges_attributes: charges_attributes,
        payment_gateway_fee_cents: balance.try(:payment_gateway_fee_cents).to_i
      }.merge(success? ? success_attributes : fail_attributes)
    end

    def transfer_id
      params['transfer']
    end

    private

    def params
      response.try(:params) || {}
    end

    def charges_attributes
      {
        '0': {
          response: response,
          success: response.success?
        }
      }
    end

    def success_attributes
      {
        state: :paid,
        paid_at: Time.zone.now
      }
    end

    def fail_attributes
      {
        state: :failed,
        failed_at: Time.zone.now
      }
    end

    def balance
      return unless params['balance_transaction']
      @balance ||= payment_gateway.find_balance(
        params['balance_transaction'],
        payment_gateway.direct_charge? ? merchant_account.try(:external_id) : nil
      )
    end
  end
end
