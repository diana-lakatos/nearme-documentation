# frozen_string_literal: true
class SubmitForm
  class LegacyCustomCode
    def initialize(controller, &block)
      @controller = controller
      @block = block
    end

    def notify(**)
      @block.call(@controller)
    end
  end
end
