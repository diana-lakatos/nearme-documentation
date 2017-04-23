# frozen_string_literal: true
module Api
  module V4
    module User
      class OrdersController < Api::V4::User::BaseController
        skip_before_action :require_authorization
        before_action :authorize_action, only: [:update]

        def update
          if order_form.validate(params[:form].presence || {})
            order_form.save
            raise ArgumentError, "Order was not saved: #{model.errors.full_messages.join(', ')}" if model.changed?

            publish_event!
            model.lister_confirmed! if order_form.try(:lister_confirm)
            model.schedule_expiry if order_form.try(:schedule_expiry)
            payment.authorized? ? payment.capture! : payment.purchase! if order_form.try(:with_charge)
          end
          respond(order_form)
        end

        protected

        def model
          @model ||= order_form.model
        end

        def payment
          @payment ||= model.payment
        end

        def order
          @order ||= Order.where('id = :id AND (user_id = :user_id OR creator_id = :user_id)',
                                 id: params[:id], user_id: current_user.id).first.tap do |o|
            raise ActiveRecord::NotFound if o.nil?
          end
        end

        def authorize_action
          raise ArgumentError if !lister? && %w(confirm complete host_cancel).include?(state_event)
          raise ArgumentError if !enquirer? && %w(user_cancel).include?(state_event)
        end

        def state_event
          @state_event ||= order_form.state_event
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

        def order_form
          @order_form ||= form_configuration.build(order)
        end

        def publish_event!
          WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::OrderUpdated,
                                  order.id, metadata: { state_event: state_event }, as: current_user)
        end
      end
    end
  end
end
