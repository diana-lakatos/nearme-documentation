  module Billing::User
    extend ActiveSupport::Concern

    included do
      has_many :charges, foreign_key: :user_id, dependent: :destroy
    end

    def billing_gateway(currency, instance)
      @billing_gateway ||= Billing::Gateway.new(self, currency, instance)
    end

  end
