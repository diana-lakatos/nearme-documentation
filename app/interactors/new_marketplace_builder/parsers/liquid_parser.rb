# frozen_string_literal: true
module NewMarketplaceBuilder
  module Parsers
    class LiquidParser
      LIQUID_CONFIG_REGEX = /\A---(.|\n)*?---\n/
      STRIPPED_FOLDER_NAME_REGEX = %r{^/?(liquid_views|mailers|sms)/}

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
          attributes['format'] ||= file_format
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
                  .gsub(STRIPPED_FOLDER_NAME_REGEX, '')
      end

      def file_format
        file_format = @file_path.split('.')[1]
        file_format == 'liquid' ? 'html' : file_format
      end
    end
  end
end
