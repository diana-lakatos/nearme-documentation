# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class AuthorizationPolicyConverter < BaseConverter
      primary_key :name
      properties :name, :content, :redirect_to

      def scope
        AuthorizationPolicy.where(instance_id: @model.id)
      end
    end
  end
end
