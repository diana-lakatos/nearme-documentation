# frozen_string_literal: true
module Elastic
  class Factory
    def initialize(config:)
      @config = config
    end

    def build(version: 0)
      Elastic::Index.new name: template.index_name(version: version),
                         body: {
                           aliases: template.aliases(version: version),
                           mappings: template.mappings,
                           settings: template.settings
                         },
                         alias_name: template.index_name(version: 'alias'),
                         version: version
    end

    private

    def template
      IndexTemplate.new config: @config
    end

    class IndexTemplate
      def initialize(config:)
        @config = config
      end

      def index_name(version:)
        @config.index_name(version: version)
      end

      def aliases(version: 0)
        return {} unless version.zero?

        { index_name(version: 'alias') => {} }
      end

      def mappings
        @config.doc_types.each_with_object({}) do |(_name, doc_type), memo|
          memo.merge! doc_type.mapping
        end
      end

      def settings
        { index: { number_of_shards: 1 } }
      end
    end
  end
end
