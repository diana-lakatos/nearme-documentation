module MarketplaceBuilder
  module Serializers
    class PageSerializer < BaseSerializer
      resource_name -> (p) { "pages/#{p.path.underscore}" }

      properties :slug, :content, :redirect_url, :redirect_code

      property :name
      property :layout

      def name(page)
        page.path
      end

      def layout(page)
        page.layout_name
      end

      def scope
        Page.where(instance_id: @model.id).all
      end
    end
  end
end
