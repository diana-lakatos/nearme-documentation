# frozen_string_literal: true
class SubmitForm
  class LegacySetFlashMessage
    def initialize(controller, key, message)
      @controller = controller
      @key = key
      @message = message
    end

    def notify(**)
      @controller.send(:flash)[@key] = @message
    end
  end
end
