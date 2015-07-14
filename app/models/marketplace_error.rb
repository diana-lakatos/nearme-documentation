class MarketplaceError < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid
end
