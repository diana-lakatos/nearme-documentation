module NewMarketplaceBuilder
  module Services
    class ImportFilesMatcher
      def initialize(parser, converters_config)
        @parser = parser
        @converters_config = converters_config
      end

      def group_files_by_patterns
        while(builder_file = @parser.next())
          group_builder_file builder_file
        end

        grouped_files_hash.to_h
      end

      private

      def group_builder_file(builder_file)
        patterns.each do |pattern|
          if builder_file[:path] =~ Regexp.new(pattern)
            grouped_files_hash[pattern].push builder_file
            break
          end
        end
      end

      def grouped_files_hash
        @grouped_files_hash ||= empty_grouped_files_hash
      end

      def empty_grouped_files_hash
        patterns.map {|converter_pattern| [converter_pattern, []] }.to_h
      end

      def patterns
        @converters_config.keys
      end
    end
  end
end
