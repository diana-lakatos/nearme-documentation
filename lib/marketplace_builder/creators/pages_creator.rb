# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class PagesCreator < TemplatesCreator
      private

      def object_name
        'Page'
      end

      def cleanup!
        @instance.theme.pages.destroy_all
      end

      def create!(template)
        slug = template.name.parameterize
        page = @instance.theme.pages.where(slug: slug).first_or_initialize
        page.path = template.name
        page.content = template.body
        page.save
      end
    end
  end
end
