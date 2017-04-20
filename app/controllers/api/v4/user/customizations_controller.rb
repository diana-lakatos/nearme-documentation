# frozen_string_literal: true
module Api
  class V4::User::CustomizationsController < Api::V4::User::BaseController
    # skip_before_action :require_authorization
    before_action :build_form, only: [:create]

    def create
      @customization_form.save if @customization_form.validate(params[:customization])
      respond(
        @customization_form,
        location: session.delete(:user_return_to).presence || params[:return_to].presence || root_path
      )
    end

    protected

    def build_form
      @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id]) if params[:form_configuration_id].present?
      @customization_form = @form_configuration&.build(get_customization)
    end

    def get_customization
      custom_model_type.customizations.new(user: current_user)
    end

    def custom_model_type
      @custom_model_type ||= CustomModelType.includes(:custom_attributes).find_by(id: params[:custom_model_type_id])
    end
  end
end
