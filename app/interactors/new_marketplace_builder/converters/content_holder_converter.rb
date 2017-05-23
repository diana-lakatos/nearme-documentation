# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class ContentHolderConverter < BaseConverter
      primary_key :name
      properties :name, :inject_pages, :position, :enabled, :content

      def scope
        ContentHolder.where(instance_id: @model.id)
      end
    end
  end
end
