module Metadata
  module IndustryMetadata
    extend ActiveSupport::Concern

    included do

      after_commit :populate_companies_industries_metadata!

      def populate_companies_industries_metadata!
        companies.find_each(&:populate_industries_metadata!)
      end

    end

  end
end
