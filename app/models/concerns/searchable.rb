module Searchable
  extend ActiveSupport::Concern

  included do
    include QuerySearchable
    include Elasticsearch::Model

    after_commit on: :create, if: lambda { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform(:index, self.class.to_s, self.id)
    end
    after_commit on: :update, if: lambda { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform((self.deleted? ? :delete : :update), self.class.to_s, self.id)
    end
    after_commit on: :destroy, if: lambda { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform(:delete, self.class.to_s, self.id)
    end

    include "#{self.to_s.demodulize.pluralize}Index".constantize
  end
end
