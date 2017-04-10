# frozen_string_literal: true
module MarketplaceBuilder
  module Serializers
    class ContentHolderSerializer < BaseSerializer
      resource_name ->(c) { "content_holders/#{c.name.parameterize('_')}" }

      properties :name, :inject_pages, :position, :content, :enabled

      def scope
        ContentHolder.where(instance_id: @model.id).all
      end
    end
  end
end
