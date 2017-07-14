# frozen_string_literal: true
class SubmitForm
  class LegacyDisplayValidationErrors
    def initialize(controller, key: :error)
      @controller = controller
      @key = key
    end

    def notify(form:, **)
      @controller.send(:flash)[@key] = ErrorsSummary.new(form).summary(separator: "\n")
    end
  end
end
