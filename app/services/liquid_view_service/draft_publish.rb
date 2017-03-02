# frozen_string_literal: true
module LiquidViewService
  class DraftPublish
    def initialize(draft)
      @liquid_view = draft
    end

    def call
      ActiveRecord::Base.transaction do
        currently_published_for_draft.destroy && save || throw(ActiveRecord::Rollback)
      end
      @liquid_view
    end

    private

    def save
      @liquid_view.save if liquid_valid?
    end

    def liquid_valid?
      @liquid_view.valid?
    end

    def currently_published_for_draft
      @liquid_view.published_version
    end
  end
end
