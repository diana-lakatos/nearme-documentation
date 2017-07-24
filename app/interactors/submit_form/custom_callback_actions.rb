# frozen_string_literal: true
class SubmitForm
  class CustomCallbackActions
    def notify(form:, form_configuration:, current_user:, params:)
      return if form_configuration.nil? # for backwards compatibility
      return if form_configuration.callback_actions.blank?

      execute_action(
        form_configuration.callback_actions,
        current_user: current_user,
        form: form,
        params: params
      )
    end

    private

    def execute_action(action_code, data)
      Liquify::LiquidTemplateParser.new(raise_mode: true).parse(action_code, data)
    end
  end
end
