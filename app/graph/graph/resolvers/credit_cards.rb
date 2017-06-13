# frozen_string_literal: true
module Graph
  module Resolvers
    class CreditCards
      def call(_, arguments, _ctx)
        resolve_by(arguments)
      end

      def resolve_by(arguments)
        arguments.keys.reduce(::CreditCard.includes(:instance_client)) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def resolve_by_user_id(relation, id)
        relation.where(instance_clients: { client_id: id, client_type: 'User' })
      end

      def resolve_by_payment_method_id(relation, id)
        relation.where(payment_method_id: id)
      end
    end
  end
end
