# frozen_string_literal: true
module LiquidViewService
  class DraftCreate
    def initialize(liquid_view)
      @currently_published = liquid_view
    end

    def call
      @liquid_view = instance_view_clone
      @liquid_view.draft = true
      @currently_published.restore_attributes
      save_without_validation
      @liquid_view
    end

    private

    def save_without_validation
      @liquid_view.save(validate: false)
    end

    def instance_view_clone
      @currently_published.dup.tap do |view|
        view.locales = @currently_published.locales
        view.transactable_types = @currently_published.transactable_types
      end
    end
  end
end
