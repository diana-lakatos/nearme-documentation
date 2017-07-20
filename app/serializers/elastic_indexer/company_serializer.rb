# frozen_string_literal: true
module ElasticIndexer
  class CompanySerializer < BaseSerializer
    attributes :id, :name, :url, :description
  end
end
