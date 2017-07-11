# frozen_string_literal: true
module Graph
  module Resolvers
    class Customizations
      attr_reader :scope, :arguments

      def call(parent_object, arguments, _ctx)
        @parent_object = parent_object
        @scope = initial_scope
        @arguments = arguments

        resolve
      end

      def resolve
        resolve_argument :id do |value, scope|
          scope.where(id: value)
        end

        resolve_argument :user_id do |value, scope|
          scope.where(user_id: value)
        end

        resolve_argument :name do |value, scope|
          scope.includes(:custom_model_type).where(
            custom_model_types: {
              parameterized_name: value
            }
          )
        end
      end

      private

      def resolve_arguments
        @scope = yield(scope)
      end

      def resolve_argument(argument)
        return unless arguments.key? argument

        @scope = yield(arguments[argument], scope)
      end

      def initial_scope
        initial_relation = ::Customization
        return initial_relation unless @parent_object

        initial_relation.where(
          customizable_type: @parent_object.class.name,
          customizable_id: @parent_object.id
        )
      end
    end
  end
end
