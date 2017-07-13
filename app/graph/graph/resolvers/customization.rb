# frozen_string_literal: true
module Graph
  module Resolvers
    class Customization
      attr_reader :scope, :arguments, :conditions

      def call(_, arguments, _ctx)
        @conditions = {}
        @scope = ::Customization.includes(:custom_model_type).all
        @arguments = arguments

      end

      def resolve
        resolve_argument :id do |value|
          { id: value }
        end

        resolve_argument :custom_model_type_name do |value|
          { custom_model_types: { parameterized_name: value } }
        end

        find_by_conditions
      end

      private

      def find_by_conditions
        scope.find_by(conditions)
      end

      def resolve_argument(argument)
        return unless arguments.key? argument

        @conditions.merge(yield(arguments[argument]))
      end
    end
  end
end
