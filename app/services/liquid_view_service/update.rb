# frozen_string_literal: true
module LiquidViewService
  class Update
    def initialize(liquid_view)
      @liquid_view = liquid_view
    end

    def call
      save
      @liquid_view
    end

    private

    def liquid_valid?
      @liquid_view.valid?
    end

    def save
      @liquid_view.save if liquid_valid?
    end
  end
end
