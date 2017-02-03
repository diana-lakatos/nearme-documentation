# frozen_string_literal: true
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

          define_method(key) { custom_property_type_cast(@hash[key], type.to_s.to_sym) }
          define_method("#{key}?") { send(key.to_s) } if type == :boolean
          if type == :array
            define_method("#{key}=") do |val|
              @model.send("#{store_accessor_name}_will_change!")
              @hash[key] = if val.is_a?(Array)
                             val.join(',')
                           else
                             val
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

    def skip_custom_attribute_validation
      @model.skip_custom_attribute_validation
    end

    def custom_validators
      @model.custom_attribute_custom_validators
    end

    def persisted?
      false
    end

    def save
      true
    end

    def update_hash(hash)
      @hash = hash
    end

    def [](key)
      send(key)
    end

    def []=(key, value)
      send("#{key}=", value)
    end

    def to_liquid
      @casted_hash ||= @model.custom_attributes.each_with_object({}) do |custom_attributes_array, results|
        key = custom_attributes_array[CustomAttribute::NAME]
        type = custom_attributes_array[CustomAttribute::ATTRIBUTE_TYPE].to_sym

        results[key] = custom_property_type_cast(@hash[key], type.to_s.to_sym)
        results
      end
    end
  end
end
