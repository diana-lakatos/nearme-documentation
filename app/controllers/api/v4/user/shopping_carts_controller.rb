# frozen_string_literal: true
module Api
  module V4
    module User
      class ShoppingCartsController < Api::V4::User::BaseController
        def create
          SubmitForm.new(
            form_configuration: form_configuration,
            form: shopping_cart_form,
            params: form_params,
            current_user: current_user
          ).call
          respond(shopping_cart_form)
        end

        def update
          SubmitForm.new(
            form_configuration: form_configuration,
            form: shopping_cart_form,
            params: form_params,
            current_user: current_user
          ).call
          respond(shopping_cart_form)
        end

        protected

        def form_params
          params[:form].presence || params[:shopping_cart].presence || {}
        end

        def shopping_cart_form
          @shopping_cart_form ||= form_configuration.build(ShoppingCart.get_for_user(current_user))
        end
      end
    end
  end
end
