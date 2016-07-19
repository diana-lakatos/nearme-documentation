require 'forwardable'

module CustomAttributes
  class CollectionProxy
    include ActiveModel::Validations
    include Enumerable
    include ::CustomAttributes::Concerns::Models::Castable

    delegate :each, to: :@hash

    def initialize(model, store_accessor_name)
      @model = model
      metaclass = class << self; self; end

      metaclass.class_eval do
        model.custom_attributes.each do |custom_attributes_array|
          key = custom_attributes_array[CustomAttribute::NAME]
          type = custom_attributes_array[CustomAttribute::ATTRIBUTE_TYPE].to_sym

          define_method(key) { custom_property_type_cast(@hash[key], "#{type}".to_sym) }
          define_method("#{key}?") { self.send("#{key}") } if type == :boolean
          if type == :array
            define_method("#{key}=") do |val|
              @model.send("#{store_accessor_name}_will_change!")
              if val.kind_of?(Array)
                @hash[key] = val.join(',')
              else
                @hash[key] = val
              end
            end
          else
            define_method("#{key}=") do |val|
              @model.send("#{store_accessor_name}_will_change!")
              @hash[key] = val
            end
          end
        end
      end
    end

    def persisted?
      false
    end

    def update_hash(hash)
      @hash = hash
    end

    def [](key)
      self.send(key)
    end

    def []=(key, value)
      send("#{key}=", value)
    end

    def to_liquid
      @hash
    end

  end
end
