# frozen_string_literal: true
class MarketplaceReportDrop < BaseDrop
  # @!method id
  #   @return [Integer] numeric identifier of the marketplace report object
  delegate :id, to: :source
end
