module NewMarketplaceBuilder
  module Parsers
    class YamlParser
      def initialize(raw_source, _file_path)
        @raw_source = raw_source
      end

      def parse
        YAML::load(@raw_source)
      end
    end
  end
end
