module Metadata
  module CompanyIndustryMetadata
    extend ActiveSupport::Concern

    included do

      delegate :populate_industries_metadata!, :to => :company, :prefix => true
      after_commit :company_populate_industries_metadata!

    end

  end
end
