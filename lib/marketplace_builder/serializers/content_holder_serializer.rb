module MarketplaceBuilder
  module Serializers
    class ContentHolderSerializer < BaseSerializer
      resource_name -> (c) { "content_holders/#{c.name.underscore}" }

      properties :name, :inject_pages, :position, :content, :enabled

      def scope
        ContentHolder.where(instance_id: @model.id).all
      end
    end
  end
end
