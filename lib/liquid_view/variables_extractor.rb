# frozen_string_literal: true
class LiquidView
  class VariablesExtractor
    WHITELISTED_CLASSES = [String, Integer, Float,
                           Array, Hash, Set, Date, DateTime,
                           Time, ActiveSupport::TimeWithZone].freeze

    class << self
      def variables(context)
        @context = context
        public_variables.tap do |pv|
          pv.select! { |variable_name| value_relevant?(variable_value(variable_name)) }
        end
      end

      protected

      def value_relevant?(value)
        value.respond_to?(:to_liquid) || WHITELISTED_CLASSES.any? { |klass| value.is_a?(klass) }
      end

      def public_variables
        @context.instance_variables - LiquidView::PROTECTED_INSTANCE_VARIABLES
      end

      def variable_value(variable_name)
        @context.instance_variable_get(variable_name)
      end
    end
  end
end
