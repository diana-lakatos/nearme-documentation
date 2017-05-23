# frozen_string_literal: true
module MarketplaceReports
  class MarketplaceReportsGenerator
    def initialize(type:, params:)
      @report_type = type
      @params = params
    end

    def generate_report_file
      compressed_file_path = MarketplaceReports::CompressedZipReport.new(csv, 'csv').compress
      begin
        yield compressed_file_path
      ensure
        FileUtils.rm(compressed_file_path)
      end
    end

    private

    def generate_csv
      scope_class = @report_type.constantize
      scope_class = scope_class.includes(location: :location_address) if scope_class == Transactable
      resources = SearchService.new(scope_class.order(created_at: 'ASC')).search(@params)
      MarketplaceReports::CollectionExporter.new(resources).export_data_to_csv
    end

    def csv
      @csv ||= generate_csv
    end
  end
end
