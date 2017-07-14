# frozen_string_literal: true
module Api
  module V4
    module User
      class OrderItemsController < Api::V4::User::BaseController
        skip_before_action :require_authorization
        before_action :authorize_action, only: [:update]

        def update
          SubmitForm.new(
            form_configuration: form_configuration,
            form: order_item_form,
            params: form_params,
            current_user: current_user
          ).call
          respond(order_item_form)
        end

        protected

        def form_params
          params[:form].presence || {}
        end

        def model
          @model ||= order_item_form.model
        end

        def order
          @order ||= Order.find_by!('id = :id AND (user_id = :user_id OR creator_id = :user_id)',
                                    id: params[:order_id], user_id: current_user.id)
        end

        def order_item
          @order_item ||= order.order_items.find(params[:id])
        end

        def authorize_action
          raise ArgumentError if !lister? && %w(cencel_by_lister).include?(state_event)
          raise ArgumentError if !enquirer? && %w(cencel_by_enquirer cancel_by_enquirer_with_payment).include?(state_event)
        end

        def state_event
          @state_event ||= order_item_form.try(:state_event)
        end

        def lister?
          current_user.id == order.creator_id
        end

        def enquirer?
          current_user.id == order.user_id
        end

        def reservation?
          model.is_a?(Reservation)
        end

        def order_item_form
          @order_item_form ||= form_configuration.build(order_item)
        end
      end
    end
  end
end
