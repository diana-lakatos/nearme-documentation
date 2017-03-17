# frozen_string_literal: true
module Modelable
  extend ActiveSupport::Concern

  included do
    has_paper_trail
    acts_as_paranoid
    auto_set_platform_context
    scoped_to_platform_context

    belongs_to :instance

    def current_instance
      @current_instance ||= PlatformContext.current.instance
    end

    def self.current_instance
      @current_instance ||= PlatformContext.current.instance
    end
  end
end
