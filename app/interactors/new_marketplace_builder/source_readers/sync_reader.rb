module NewMarketplaceBuilder
  module SourceReaders
    class SyncReader
      def initialize(source_params)
        @source_params = source_params
        @finished = false
      end

      def next
        return nil if @finished
        @finished = true

        { path: @source_params[:path], content: @source_params[:marketplace_builder_file_body] }
      end
    end
  end
end
