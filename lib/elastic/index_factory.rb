module Elastic
  class IndexNameBuilder
    def initialize(*attributes)
      @attributes = attributes
    end

    def build(version: 0)
      IndexName.new(base, to_name(base, version), version)
    end

    def alias_name
      base
    end

    def self.load(data)
      *name, version = *data.keys.first.split('-')

      IndexNameBuilder.new(*name).build(version: version.to_i)
    end

    private

    def base
      to_name @attributes
    end

    def to_name(*args)
      args.join('-')
    end
  end

  class IndexName < Struct.new(:alias_name, :name, :version)
  end
end
