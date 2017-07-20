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
          SubmitForm.new(
            form_configuration: form_configuration,
            form: customization_form,
            params: form_params,
            current_user: current_user
          ).call
          respond(customization_form)
        end

        def destroy
          SubmitForm.new(
            form_configuration: form_configuration,
            form: customization_form,
            params: form_params,
            current_user: current_user
          ).tap do |submit_form|
            submit_form.add_success_observer(SubmitForm::DestroyModel.new)
          end.call
          respond(customization_form)
        end

        protected

        def form_params
          params[:form].presence || params[:customization] || {}
        end

        def customization
          @customization ||= if params[:id]
                               Customization.find(params[:id])
                             else
                               custom_model_type.customizations.new(user: current_user)
                             end
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
