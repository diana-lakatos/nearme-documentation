module Spree::Scoper
  extend ActiveSupport::Concern

  included do
    auto_set_platform_context
    scoped_to_platform_context
  end
end
