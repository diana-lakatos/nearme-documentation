# frozen_string_literal: true
module Api
  module V4
    module User
      class CustomizationsController < Api::V4::User::BaseController
        def create
          customization_form.save if customization_form.validate(params[:form].presence || params[:customization] || {})
          respond(customization_form)
        end

        protected

        def customization_form
          @customization_form ||= form_configuration&.build(custom_model_type.customizations.new(user: current_user))
        end

        def custom_model_type
          @custom_model_type ||= CustomModelType.includes(:custom_attributes).find_by(id: params[:custom_model_type_id])
        end
      end
    end
  end
end
