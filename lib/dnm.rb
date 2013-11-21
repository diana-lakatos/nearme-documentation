# rescue_from EmptyParameter, :with => :param_error

module DNM

  class Unauthorized < ::StandardError
    def initialize(msg = "Invalid Authentication")
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

  class InvalidJSON < Error
    def initialize(msg = "Body should be a JSON Hash")
      super msg
      @status = 400
    end
  end

  class MissingJSONData < Error
    def initialize(field, msg = "Missing Data")
      super msg
      @errors << { resource: "JSON",
                   field:    field,
                   code:     "missing_field" }
      @status = 400
    end
  end

  class InvalidJSONData < Error
    def initialize(field, msg = "Invalid Data")
      super msg
      if field.present?
        @errors << { resource: "JSON",
                     field:    field,
                     code:     "invalid" }
      end
      @status = 400
    end
  end

  class InvalidJSONDate < Error
    def initialize(field, msg = "Date is in the past")
      super msg
      if field.present?
        @errors << { resource: "JSON",
                     field:    field,
                     code:     "invalid" }
      end
      @status = 400
    end
  end

  class RecordNotFound < Error
    def initialize(resource, field, msg = "Record Not Found")
      super msg
      @errors << { resource:  resource,
                   field:     field,
                   code:      "missing" }
      @status = 404
    end
  end

  class UnauthorizedButUserExists < Error
    def initialize(msg = "Invalid Authentication")
      super msg
      @errors << { resource:  "User",
                   field:     "email",
                   code:      "already_exists" }
      @status = 401
    end
  end

  class PropertyUnavailableOnDate < Error
    def initialize(date, requested, msg = "Property unavailable")
      super msg
      @errors << {
          date: date,
          requested: requested
      }
      @status = 400
    end
  end

  module MAIL_TYPES
    BULK = 'bulk'
    TRANSACTIONAL = 'transactional'
    NON_TRANSACTIONAL = 'non_transactional'
  end

end
