module Searchable
  extend ActiveSupport::Concern

  included do
    include QuerySearchable
    include Elasticsearch::Model

    after_commit on: :create, if: -> { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform(:index, self.class.to_s, id)
    end
    after_commit on: :update, if: -> { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform((self.deleted? ? :delete : :update), self.class.to_s, id)
    end
    after_commit on: :destroy, if: -> { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform(:delete, self.class.to_s, id)
    end

    include "#{to_s.demodulize.pluralize}Index".constantize
  end
end
