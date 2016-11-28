# frozen_string_literal: true
class ThirdPartyIntegration < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  TYPES = %w(ThirdPartyIntegration::LongtailIntegration).freeze

  belongs_to :instance

  validates :type, :environment, presence: true
  validates :type, inclusion: { in: TYPES }

  serialize :settings, Hash
end
