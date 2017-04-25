module NewMarketplaceBuilder
  module Factories
    class SourceReaderFactory
      def initialize(source)
        @source = source
      end

      def reader
        case @source
        when String                       then SourceReaders::PathReader.new(@source)
        when ActionController::Parameters then SourceReaders::SyncReader.new(@source)
        when MarketplaceReleaseUploader   then SourceReaders::ZipReader.new(@source.file)
        else
          raise('MarketplaceBuilder: Invalid source passed to import interactor!')
        end
      end
    end
  end
end
