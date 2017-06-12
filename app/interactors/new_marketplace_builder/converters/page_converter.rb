# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class PageConverter < BaseConverter
      primary_key :slug
      properties :content, :layout_name, :redirect_url, :redirect_code, :slug, :path,
        :format, :metadata_title, :metadata_meta_description, :metadata_canonical_url,
        :require_verified_user
      property :name

      def name(page)
        File.basename(page.path, '.*').sub(/^_/, '').humanize.titleize
      end

      def scope
        Page.where(instance_id: @model.id, theme_id: @model.theme.id)
      end
    end
  end
end
