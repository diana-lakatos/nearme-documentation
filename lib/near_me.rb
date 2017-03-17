# frozen_string_literal: true
module NearMe
  class Unauthorized < ::StandardError
    def initialize(msg = 'Invalid Authentication')
      super
    end
  end

  class Error < ::StandardError
    attr_accessor :errors, :status

    def initialize(msg = nil)
      super
      @status ||= 422
      @errors ||= []
    end

    def to_hash
      {
        message: message,
        errors:  errors
      }
    end
  end

  class RecordNotFound < Error
    def initialize(resource, field, msg = 'Record Not Found')
      super msg
      @errors << { resource:  resource,
                   field:     field,
                   code:      'missing' }
      @status = 404
    end
  end

  class InvalidParameterValue < Error
    def initialize(parameter, value)
      super "Invalid value for #{parameter}: #{value}. See documentation for valid values."
    end
  end
end
