# frozen_string_literal: true
module LiquidViewService
  class Builder
    def initialize(liquid_view)
      @liquid_view = liquid_view
    end

    def call(template_params)
      assign_attributes(template_params)

      strategy.new(@liquid_view).call
    end

    private

    def assign_attributes(params)
      @liquid_view.assign_attributes params.except(:path)
    end

    def strategy
      if @liquid_view.draft_changed? && @liquid_view.draft?
        DraftCreate
      elsif @liquid_view.draft_changed? && !@liquid_view.draft?
        DraftPublish
      elsif @liquid_view.draft?
        DraftUpdate
      else
        Update
      end
    end
  end
end
