# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class ContentHoldersCreator < TemplatesCreator
      private

      def cleanup!
        @instance.theme.content_holders.destroy_all
      end

      def default_template_options
        {
          inject_pages: 'any_page',
          position: 'head_bottom'
        }
      end

      def object_name
        'ContentHolder'
      end

      def create!(template)
        template.inject_pages = [template.inject_pages] if template.inject_pages.is_a?(String)

        ch = @instance.theme.content_holders.where(
          name: template.name
        ).first_or_initialize

        ch.update!(content: template.body,
                   inject_pages: template.inject_pages,
                   position: template.position)
      end
    end
  end
end
