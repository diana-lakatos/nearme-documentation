# frozen_string_literal: true
module Api
  module V4
    module User
      class CustomizationsController < Api::V4::User::BaseController
        def create
          SubmitForm.new(
            form_configuration: form_configuration,
            form: customization_form,
            params: form_params,
            current_user: current_user
          ).call
          respond(customization_form)
        end

        def update
          command = CustomizationUpdate.new(current_user: current_user, id: params[:id], params: form_params, form_configuration_id: form_configuration.id)
          command.call
          respond(command.form)
        end

        def destroy
          command = CustomizationDelete.new(current_user: current_user, id: params[:id], params: form_params, form_configuration_id: form_configuration.id)
          command.call
          respond(command.form)
        end

        protected

        def form_params
          params[:form].presence || params[:customization] || {}
        end

        def customization
          @customization ||= custom_model_type.customizations.new(user: current_user)
        end

        def customization_form
          @customization_form ||= form_configuration&.build(customization)
        end

        def custom_model_type
          @custom_model_type ||= CustomModelType.includes(:custom_attributes).find_by(id: params[:custom_model_type_id])
        end
      end
    end
  end
end
