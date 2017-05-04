module NewMarketplaceBuilder
  module Jobs
    class MarketplaceBuilderJob < Job
      def after_initialize(marketplace_release_id)
        @marketplace_release = MarketplaceRelease.find(marketplace_release_id)
      end

      def perform
        if @marketplace_release.ready_for_import?
          NewMarketplaceBuilder::Interactors::ImportInteractor.new(@marketplace_release.instance_id, @marketplace_release.zip_file).execute!
        elsif @marketplace_release.ready_for_export?
          NewMarketplaceBuilder::Interactors::ExportInteractor.new(@marketplace_release.instance_id, @marketplace_release).execute!
        end

        @marketplace_release.update! status: 'success'
      rescue StandardError => e
        @marketplace_release.update! status: "error", error: e.message
        raise e if Rails.env.development?
      end
    end
  end
end

