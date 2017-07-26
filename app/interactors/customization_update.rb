# frozen_string_literal: true
class CustomizationUpdate
  def initialize(current_user:, id:, params:, form_configuration_id:)
    @current_user = current_user
    @id = id
    @params = params
    @form_configuration_id = form_configuration_id
  end

  def call
    SubmitForm.new(
      form_configuration: form_configuration,
      form: form,
      params: @params,
      current_user: @current_user
    ).call
  end

  def form
    @form ||= form_configuration.build(customization)
  end

  private

  def customization
    @customization ||= Customization.find(@id)
  end

  def form_configuration
    @form_configuration ||= FormConfiguration.find_by(id: @form_configuration_id).tap do |fc|
      Authorize.new(object: fc, user: @current_user, params: @params).call
    end
  end
end
