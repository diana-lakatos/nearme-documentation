# frozen_string_literal: true
module MarketplaceReports
  class CollectionExporter
    def initialize(resources)
      @resources = resources
    end

    def export_data_to_csv
      return "" if @resources.empty?

      case @resources.first
      when Transactable
        MarketplaceReports::TransactableReportExporter
      when User
        MarketplaceReports::UserReportExporter
      end.new(@resources).export_data_to_csv
    end
  end
end
