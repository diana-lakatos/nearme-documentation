# frozen_string_literal: true
class FormConfiguration
  class FormObjectFactory
    ALLOWED_OBJECT_CLASSES = %w(User UserProfile Transactable Customization).freeze
    ALLOWED_OBJECT_PARENT_CLASSES = %w(InstanceProfileType TransactableType CustomModelType).freeze
    class << self
      def object(object_class:, object_id:, parent_object_class: nil, parent_object_id: nil)
        user_input_sanity_check!(object_class, object_id, parent_object_class)
        if object_id == 'new'
          if parent_object_id && parent_object_class
            parent_object_class.constantize.find(parent_object_id).association(object_class).build
          else
            object_class.constantize.new
          end
        else
          object_class.constantize.find(object_id)
        end
      end

      protected

      def invalid_parent_class?(klass)
        klass.present? && !ALLOWED_OBJECT_PARENT_CLASSES.include?(klass)
      end

      def invalid_class?(klass)
        klass.present? && !ALLOWED_OBJECT_CLASSES.include?(klass)
      end

      def user_input_sanity_check!(object_class, object_id, parent_object_class)
        raise ArgumentError, "#{parent_object_class} is not valid class name" if invalid_parent_class?(parent_object_class)
        raise ArgumentError, "#{object_class} is not valid class name" if invalid_class?(object_class)
        raise ArgumentError, "Object id for class #{object_class} is nil. Please pass 'new' or integer." if object_id.nil?
      end
    end
  end
end
