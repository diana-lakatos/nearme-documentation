# frozen_string_literal: true
class FormConfiguration
  class FormObjectFactory
    class << self
      def object(object_class:, object_id:)
        case object_id
        when 'new'
          object_class.constantize.new
        when nil
          raise ArgumentError, "Object id for class #{object_class} is nil. If you want to create new object, pass 'new' explicitly"
        else
          object_class.constantize.find(object_id)
        end
      end
    end
  end
end
