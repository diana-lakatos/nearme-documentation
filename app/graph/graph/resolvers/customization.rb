# frozen_string_literal: true
module Graph
  module Resolvers
    class Customization
      attr_reader :scope, :arguments, :conditions

      def call(_, arguments, _ctx)
        @conditions = {}
        @scope = ::Customization.includes(:custom_model_type).all
        @arguments = arguments

        resolve
      end

      def resolve
        resolve_argument :id do |value|
          @conditions[:id] = value
        end

        resolve_argument :name do |value|
          @conditions[:custom_model_types] = { parameterized_name: value }
        end

        find_by_conditions
      end

      private

      def find_by_conditions
        scope.find_by(@conditions)
      end

      def resolve_argument(argument)
        return unless arguments.key? argument
        yield(arguments[argument])
      end
    end
  end
end
