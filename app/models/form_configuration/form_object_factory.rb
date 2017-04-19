# frozen_string_literal: true
class FormConfiguration
  class FormObjectFactory
    ALLOWED_OBJECT_CLASSES = %w(User UserProfile Transactable Customization ShoppingCart CheckoutShoppingCart Order).freeze
    ALLOWED_OBJECT_PARENT_CLASSES = %w(User InstanceProfileType TransactableType CustomModelType).freeze
    CUSTOM_CLASSES = %w(ShoppingCart CheckoutShoppingCart).freeze

    def initialize(object_class:, object_id: nil, parent_object_class: nil, parent_object_id: nil, **)
      @object_class = object_class
      @object_id = object_id
      @parent_object_class = parent_object_class
      @parent_object_id = parent_object_id
      raise ArgumentError, "#{@parent_object_class} is not a valid class name" if invalid_parent_class?(@parent_object_class)
      raise ArgumentError, "#{@object_class} is not a valid class name" if invalid_class?(@object_class)
      raise ArgumentError, "Object id for class #{@object_class} is nil. Please pass 'new' or integer." if @object_id.nil? && !CUSTOM_CLASSES.include?(@object_class)
    end

    def object
      if @object_class == 'ShoppingCart'
        ShoppingCart.get_for_user(parent_object)
      elsif @object_class == 'CheckoutShoppingCart'
        CheckoutShoppingCart.new(ShoppingCart.get_for_user(parent_object))
      elsif @object_id == 'new'
        new_object
      else
        fetch_object
      end
    end

    protected

    def new_object
      parent_object ? build_new_object_from_association : build_new_object
    end

    def build_new_object_from_association
      parent_object.association(object_class_name_to_association).build
    end

    def build_new_object
      @object_class.constantize.new
    end

    def fetch_object
      parent_object ? fetch_object_scoped_to_association : @object_class.constantize.find(@object_id)
    end

    def fetch_object_scoped_to_association
      parent_object.association(object_class_name_to_association).find(@object_id)
    end

    def parent_object
      return nil if @parent_object_class.blank? || @parent_object_id.blank?
      @parent_object ||= @parent_object_class.constantize.find_by(parameterized_name: @parent_object_id)
    end

    def invalid_parent_class?(klass)
      klass.present? && !ALLOWED_OBJECT_PARENT_CLASSES.include?(klass)
    end

    def invalid_class?(klass)
      klass.present? && !ALLOWED_OBJECT_CLASSES.include?(klass)
    end

    def object_class_name_to_association
      @object_class_name_to_association ||= @object_class.demodulize.pluralize.downcase
    end
  end
end
