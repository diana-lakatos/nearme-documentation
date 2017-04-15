# FIXME: concept is not perfect
# index has one name
# index might have zero one or more aliases
# index has mappings and settings
module Elastic
  class Index
    attr_reader :index_name, :type, :builder, :version

    def initialize(type:, version:, builder:)
      @type = type
      @version = version
      @builder = builder
    end

    def alias_name
      index_name.alias_name
    end

    def name
      index_name.name
    end

    def body
      {
        settings: type.body[:settings],
        mappings: type.body[:mappings]
      }
    end

    private

    def index_name
      builder.build(version: version)
    end
  end

  class IndexZero < Index
    ZERO_VERSION = 0

    def version
      ZERO_VERSION
    end

    def body
      {
        settings: type.body[:settings],
        mappings: type.body[:mappings],
        aliases: { index_name.alias_name => {} }
      }
    end
  end
end
