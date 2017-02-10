# frozen_string_literal: true
module LiquidViewService
  class DraftUpdate
    def initialize(liquid_view)
      @liquid_view = liquid_view
    end

    def call
      save_without_validation
      @liquid_view
    end

    private

    def save_without_validation
      @liquid_view.save(validate: false)
    end
  end
end
