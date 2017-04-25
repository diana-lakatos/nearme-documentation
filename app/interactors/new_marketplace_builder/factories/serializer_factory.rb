module NewMarketplaceBuilder
  module Factories
    class SerializerFactory
      def initialize(destination)
        @destination = destination
      end

      def serializer(instance, manifest)
        case @destination
        when String             then Serializers::PathSerializer.new(instance, @destination, manifest)
        when MarketplaceRelease then Serializers::ZipSerializer.new(instance, @destination, manifest)
        else
          raise('MarketplaceBuilder: Invalid destination passed to export interactor!')
        end
      end
    end
  end
end
