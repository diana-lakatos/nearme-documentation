# frozen_string_literal: true
module Api
  module V4
    module User
      class ShoppingCartsController < Api::V4::User::BaseController
        skip_before_action :require_authorization

        def create
          shopping_cart_form.save if shopping_cart_form.validate(params[:form].presence || {})
          respond(shopping_cart_form)
        end

        def update
          # TODO: this is hotfix to recalculate hostfee properly in MyCSN
          shopping_cart_form.model.orders.each do |order|
            order.host_fee_line_items.destroy_all
            order.service_fee_line_items.destroy_all
          end

          shopping_cart_form.save if shopping_cart_form.validate(params[:form].presence || {})
          respond(shopping_cart_form)
        end

        protected

        def shopping_cart_form
          @shopping_cart_form ||= form_configuration.build(ShoppingCart.get_for_user(current_user))
        end
      end
    end
  end
end
