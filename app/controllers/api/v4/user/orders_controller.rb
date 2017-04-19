# frozen_string_literal: true
module Api
  module V4
    module User
      class OrdersController < Api::V4::BaseController
        skip_before_action :require_authorization
        before_action :find_order, only: [:update]
        before_action :authorize_action, only: [:update]

        def update
          if order_form.validate(params[:form].presence || {})
            order_form.save
            # just quick and dirty to explore our possibilites here and to not have to migrate all MPs
            raise ArgumentError, "Order was not saved: #{order_form.model.errors.full_messages.join(', ')}" if order_form.model.changed?

            if state_event == 'confirm'
              WorkflowStepJob.perform("WorkflowStep::#{@order.class.workflow_class}Workflow::ManuallyConfirmed".constantize, @order.id, as: current_user)
            elsif state_event == 'complete'
              WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Completed, @order.id)
            elsif state_event == 'host_cancel' && reservation?
              WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ListerCancelled, @order.id, as: current_user)
            elsif state_event == 'user_cancel' && reservation?
              WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::EnquirerCancelled, @order.id, as: current_user)
            else
              WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::OrderUpdated, @order.id, as: current_user)
            end
          end
          respond(order_form)
        end

        protected

        def find_order
          @order = Order.where('id = :id AND (user_id = :user_id OR creator_id = :user_id)',
                               id: params[:id], user_id: current_user.id).first
          raise ActiveRecord::NotFound unless @order.present?
        end

        def authorize_action
          raise ArgumentError if !lister? && %w(confirm complete host_cancel).include?(state_event)
          raise ArgumentError if !enquirer? && %w(user_cancel).include?(state_event)
        end

        def state_event
          @state_event ||= order_form.state_event
        end

        def lister?
          current_user.id == @order.creator_id
        end

        def enquirer?
          current_user.id == @order.user_id
        end

        def reservation?
          order_form.model.is_a?(Reservation)
        end

        def form_configuration
          @form_configuration ||= FormConfiguration.find(params[:form_configuration_id])
        end

        def order_form
          @order_form ||= form_configuration.build(@order)
        end
      end
    end
  end
end
