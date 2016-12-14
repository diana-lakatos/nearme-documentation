# frozen_string_literal: true
require 'active_support/concern'

module PaymentGateways
  module StripeCommon
    extend ActiveSupport::Concern

    def payment_url(payment)
      return unless payment.external_id
      stripe_dashboard_url + if direct_charge? && (m = payment.merchant_account).present?
                               "/#{m.external_id}#{test_mode? ? '/test' : ''}/payments/#{payment.external_id}"
                             else
                               "#{test_mode? ? '/test' : ''}/payments/#{payment.external_id}"
      end
    end

    def transfer_url(transfer)
      return unless transfer.token

      stripe_dashboard_url + if direct_charge? && (m = transfer.merchant_account).present?
                               "/#{m.external_id}#{test_mode? ? '/test' : ''}/transfers/#{transfer.token}"
                             else
                               "#{test_mode? ? '/test' : ''}/transfers/#{transfer.token}"
      end
    end

    def stripe_dashboard_url
      'https://dashboard.stripe.com'
    end
  end
end
