# frozen_string_literal: true
module Graph
  module Types
    module Payments
      MerchantAccount = GraphQL::ObjectType.define do
        name 'MerchantAccount'

        field :id, !types.ID

        field :account_type, !types.String
        field :bank_account_number, !types.String
        field :state, !types.String

        field :date_of_birth, !types.String, property: :dob_date
        field :first_name, !types.String
        field :last_name, !types.String
      end
    end
  end
end
