# frozen_string_literal: true
module Api
  module V4
    class CustomizationsController < Api::V4::BaseController
      skip_before_action :require_authentication, except: [:edit, :update, :destroy]
      skip_before_action :require_authorization

      def create
        SubmitForm.new(
          form_configuration: form_configuration,
          form: customization_form,
          params: form_params,
          current_user: current_user
        ).call
        respond(customization_form)
      end

      protected

      def form_params
        params[:form].presence || params[:customization] || {}
      end

      def customization_form
        @customization_form ||= form_configuration&.build(custom_model_type.customizations.new(user: current_user))
      end

      def custom_model_type
        @custom_model_type ||= CustomModelType.includes(:custom_attributes).find_by(id: params[:custom_model_type_id])
      end
    end
  end
end
