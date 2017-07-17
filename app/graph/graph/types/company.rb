# frozen_string_literal: true
module Graph
  module Types
    Company = GraphQL::ObjectType.define do
      name 'Company'
      description 'A firm'

      global_id_field :id

      field :id, !types.Int
      field :url, types.String
      field :name, !types.String
      field :description, types.String
      field :merchant_accounts, Graph::Types::Collection.build(Graph::Types::Payments::MerchantAccount) do
        argument :page, types.Int, default_value: 1
        argument :per_page, types.Int, default_value: 20
        resolve lambda { |obj, args, ctx|
          Graph::Types::Payments::MerchantAccountsResolver.new(::MerchantAccount.for_company(obj.id)).call(obj, args, ctx)
        }
      end
    end
  end
end
