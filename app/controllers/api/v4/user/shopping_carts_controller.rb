# frozen_string_literal: true
module Api
  module V4
    module User
      class ShoppingCartsController < Api::V4::BaseController
        skip_before_action :require_authorization
        before_action :build_shopping_cart_form, only: [:create, :update]

        def create
          @shopping_cart_form.save if @shopping_cart_form.validate(params[:form].presence || {})
          respond(@shopping_cart_form)
        end

        def update
          @shopping_cart_form.save if @shopping_cart_form.validate(params[:form].presence || {})
          respond(@shopping_cart_form)
        end

        protected

        def build_shopping_cart_form
          @form_configuration = FormConfiguration.find(params[:form_configuration_id])
          @shopping_cart_form = @form_configuration.build(ShoppingCart.get_for_user(current_user))
        end
      end
    end
  end
end
