# frozen_string_literal: true
class MarketplaceErrorGroup < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  has_many :marketplace_errors, inverse_of: :marketplace_error_group, dependent: :destroy
end
