# frozen_string_literal: true
module EventStore
  class EventDataSerializer
    def initialize(data)
      @data = data.to_h
    end

    def to_h
      serialize_value(@data)
    end

    private

    def serialize_value(value)
      case value
      when ActiveRecord::Base
        serialize_ar(value)
      when Array
        serialize_array(value)
      when Hash
        serialize_hash(value)
      else
        value
      end
    end

    def serialize_hash(value)
      value.each_with_object({}) do |(k, v), hash|
        hash[k] = serialize_value(v)
      end
    end

    def serialize_array(value)
      value.map { |v| serialize_value(v) }
    end

    def serialize_ar(value)
      { class_name: value.class.to_s, id: value.id }
    end
  end
end
