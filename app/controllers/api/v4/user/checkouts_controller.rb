# frozen_string_literal: true
module Api
  module V4
    module User
      class CheckoutsController < Api::V4::User::BaseController
        skip_before_action :require_authorization

        def create
          begin
            if checkout_form.validate(form_params)
              checkout_form.save
              WorkflowStepJob.perform(WorkflowStep::CheckoutWorkflow::Completed, shopping_cart.id, as: current_user)
              # TODO: trigger workflow step for each checkout_form.orders -> to support multiple listers  in one checkout
            end
          rescue CheckoutShoppingCart::PaymentProcessingError
            checkout_form.errors.add(:base, :payment_failed)
          end
          respond(checkout_form)
        end

        protected

        def checkout_form
          @checkout_form ||= form_configuration.build(checkout_shopping_cart)
        end

        def shopping_cart
          @shopping_cart ||= ShoppingCart.get_for_user(current_user).tap do |sc|
            raise ActiveRecord::NotFound if sc.nil?
          end
        end

        def checkout_shopping_cart
          @checkout_shopping_cart ||= CheckoutShoppingCart.new(shopping_cart)
        end

        def form_params
          params[:form].presence || {}
        end
      end
    end
  end
end
