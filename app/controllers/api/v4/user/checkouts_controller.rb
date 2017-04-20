# frozen_string_literal: true
module Api
  module V4
    module User
      class CheckoutsController < Api::V4::User::BaseController
        skip_before_action :require_authorization

        def create
          begin
            checkout_form.save if checkout_form.validate(params[:form].presence || {})
          rescue CheckoutShoppingCart::PaymentProcessingError
            checkout_form.errors.add(:base, :payment_failed)
          end
          respond(checkout_form)
        end

        protected

        def form_configuration
          @form_configuration ||= FormConfiguration.find(params[:form_configuration_id])
        end

        def checkout_form
          @checkout_form ||= form_configuration.build(CheckoutShoppingCart.new(ShoppingCart.get_for_user(current_user)))
        end
      end
    end
  end
end
