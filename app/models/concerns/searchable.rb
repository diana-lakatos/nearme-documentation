module Searchable
  extend ActiveSupport::Concern

  included do
    include QuerySearchable
    include Elasticsearch::Model

    after_commit on: :create, if: -> { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform(:index, self.class.to_s, id)
    end
    after_commit on: :update, if: -> { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform((deleted? ? :delete : :update), self.class.to_s, id)
    end
    after_commit on: :destroy, if: -> { Rails.application.config.use_elastic_search } do
      ElasticIndexerJob.perform(:delete, self.class.to_s, id)
    end

    include "#{to_s.demodulize.pluralize}Index".constantize

    index_name -> { define_index_name }

    def self.define_index_name
      raise PlatformContext::MissingContextError if PlatformContext.current.nil?
      alias_index_name
    end

    def self.base_index_name
      "#{to_s.demodulize.pluralize.downcase}-#{Rails.application.config.stack_name}-#{Rails.env}-#{PlatformContext.current.try(:instance).try(:id)}"
    end

    def self.alias_index_name
      "#{base_index_name}-alias"
    end

    def self.indexer_helper
      @elastic_indexer ||= Elastic::IndexerHelper.new(self)
    end
  end
end
