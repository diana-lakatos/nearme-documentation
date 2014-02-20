module Metadata
  module CompanyMetadata
    extend ActiveSupport::Concern

    included do

      def populate_industries_metadata!
        update_metadata({ :industries_metadata => self.reload.industries.order('name').collect(&:name) })
      end

    end

  end
end
