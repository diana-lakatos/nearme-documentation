# frozen_string_literal: true
module Graph
  module Types
    module Payments
      class MerchantAccountsResolver < Graph::Resolvers::AR::BaseResolver
        def resolve
          resolve_arguments do |args|
            Graph::Resolvers::AR::PageResolver.new(scope).call(self, args, ctx)
          end
        end

        private

        def main_scope
          @parent.merchant_accounts
        end
      end
    end
  end
end
