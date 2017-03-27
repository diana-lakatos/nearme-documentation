# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class PagesCreator < TemplatesCreator
      def cleanup!
        pages = get_templates
        return @instance.theme.pages.destroy_all if pages.empty?

        unused_pages = if pages.empty?
                         @instance.theme.pages.all
                       else
                         @instance.theme.pages.where('slug NOT IN (?)', pages.map { |page| page.slug.presence || page.name.parameterize })
                       end

        unused_pages.each { |page| logger.debug "Removing unused page: #{page.path}" }
        unused_pages.destroy_all
      end

      private

      def object_name
        'Page'
      end

      def create!(template)
        slug = template.try(:slug) || template.name.parameterize
        page = @instance.theme.pages.where(slug: slug).first_or_initialize
        page.path = template.name
        page.layout_name = template.layout_name if template.layout_name.present?
        page.content = template.body if template.body.present?
        page.redirect_url = template.redirect_url if template.redirect_url.present?
        page.redirect_code = template.redirect_code if template.redirect_code.present?
        page.save!
      end

      def success_message(template)
        msg = template.redirect_url.present? ? "#{template.name} (redirect)" : template.name
        logger.debug "Creating page: #{msg}"
      end
    end
  end
end
