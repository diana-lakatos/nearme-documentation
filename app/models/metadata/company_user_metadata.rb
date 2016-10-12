module Metadata
  module CompanyUserMetadata
    extend ActiveSupport::Concern

    included do
      after_commit :user_populate_companies_metadata!
      delegate :populate_companies_metadata!, to: :user, prefix: true, allow_nil: true
    end
  end
end
