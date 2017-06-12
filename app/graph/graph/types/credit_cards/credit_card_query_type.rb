# frozen_string_literal: true
module Graph
  module Types
    module CreditCards
      CreditCardQueryType = GraphQL::ObjectType.define do
        field :credit_cards do
          type !types[Types::CreditCards::CreditCard]

          argument :id, types.ID
          argument :user_id, types.ID
          argument :payment_method_id, types.ID
          resolve Resolvers::CreditCards.new
        end
      end
    end
  end
end
