# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class ContentHoldersCreator < TemplatesCreator
      def cleanup!
        content_holders = get_templates

        unused_content_holders = if content_holders.empty?
                                   @instance.theme.content_holders.all
                                 else
                                   @instance.theme.content_holders.where('name NOT IN (?)', content_holders.map(&:name))
                                 end

        unused_content_holders.each { |ch| logger.debug "Removing unused content holder: #{ch.name}" }
        unused_content_holders.destroy_all
      end

      private

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
