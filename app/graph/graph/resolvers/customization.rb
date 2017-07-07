# frozen_string_literal: true
module Graph
  module Resolvers
    class Customization
      def call(_, arguments, _ctx)
        ::Customization.includes(:custom_model_type).find_by(resolve_by(arguments))
      end

      def resolve_by(arguments)
        arguments.keys.reduce({}) do |conditions, argument_key|
          conditions.merge(public_send("resolve_by_#{argument_key}", arguments[argument_key]))
        end
      end

      def resolve_by_id(id)
        { id: id }
      end

      def resolve_by_custom_model_type_name(model_name)
        { custom_model_types: { parameterized_name: model_name } }
      end
    end
  end
end