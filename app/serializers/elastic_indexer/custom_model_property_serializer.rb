module ElasticIndexer
  class CustomModelPropertySerializer < ActiveModel::Serializer
    self.root = false

    def attributes
      object.each_with_object({}) do |(name, value), props|
        next unless value

        props.merge! PropertySerializer.new(name, value, definitions).as_json
      end
    end

    def definitions
      scope.custom_attributes
    end
  end

  class PropertySerializer
    attr_reader :name

    def initialize(name, value, definitions)
      @name = name
      @value = value
      @definitions = definitions
    end

    def value
      case @definitions.find_by(name: name).attribute_type
      when 'string' then @value.to_s
      when 'integer' then @value.to_i
      when 'float', 'decimal' then @value.to_f
      when 'boolean' then ActiveRecord::Type::Boolean.new.type_cast_from_database(@value)
      when 'array' then @value.split(',').map(&:strip)
      else
        @value
      end
    end

    def as_json
      Hash[name, value]
    end
  end
end
