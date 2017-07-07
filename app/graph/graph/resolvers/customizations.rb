# frozen_string_literal: true
module Graph
  module Resolvers
    class Customizations
      def call(parent_object, arguments, _ctx)
        @parent_object = parent_object
        resolve_by(arguments)
      end

      def resolve_by(arguments)
        arguments.keys.reduce(initial_relation) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def resolve_by_id(relation, id)
        relation.where(id: id)
      end

      def resolve_by_user_id(relation, id)
        relation.where(user_id: id)
      end

      def resolve_by_custom_model_type_name(relation, model_name)
        relation.includes(:custom_model_type).where(
          custom_model_types: {
            parameterized_name: model_name
          }
        )
      end

      def initial_relation
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
