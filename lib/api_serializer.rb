class ApiSerializer

  class << self
    def serialize_object(object, options = {})
      JSONAPI::Serializer.serialize(object, options)
    end

    def serialize_collection(collection, options = {})
      JSONAPI::Serializer.serialize(collection, options.merge(is_collection: true))
    end

    def serialize_errors(errors)
      JSONAPI::Serializer.serialize_errors(errors)
    end
  end
end

