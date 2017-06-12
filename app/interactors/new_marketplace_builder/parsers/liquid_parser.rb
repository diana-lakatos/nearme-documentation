module NewMarketplaceBuilder
  module Parsers
    class LiquidParser
      LIQUID_CONFIG_REGEX = /\A---(.|\n)*?---\n/

      def initialize(liquid_body, file_path)
        @liquid_body = liquid_body
        @file_path = file_path
      end

      def parse
        parse_liquid_config(@liquid_body.match(LIQUID_CONFIG_REGEX)).tap do |attributes|
          attributes['body'] ||= @liquid_body.gsub(LIQUID_CONFIG_REGEX, '')
          attributes['content'] ||= attributes['body']
          attributes['name'] ||= File.basename(parse_liquid_path)
          attributes['path'] ||= parse_liquid_path
          attributes['partial'] ||= is_partial
        end
      end

      private

      def parse_liquid_config(hash)
        return {} unless hash
        YAML.load(hash[0])
      end

      def parse_liquid_path
        liquid_path.gsub(/\/_(?=[^\/]+$)/, '/')
      end

      def is_partial
        File.basename(liquid_path).start_with?('_')
      end

      def liquid_path
        @file_path.gsub(/\.[a-z]+$/, '')
                  .gsub('/liquid_views/', '')
                  .gsub('liquid_views/', '')
                  .gsub('/mailers/', '')
                  .gsub('mailers/', '')
      end
    end
  end
end
