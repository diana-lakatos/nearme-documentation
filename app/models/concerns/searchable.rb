# frozen_string_literal: true
module Searchable
  extend ActiveSupport::Concern

  included do
    include QuerySearchable
    include Elasticsearch::Model

    after_commit :index_object_on_create, on: :create
    after_commit :index_object_on_update, on: :update
    after_commit :delete_from_index_on_destroy, on: :destroy

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

    private

    def index_object_on_create
      if Rails.application.config.use_elastic_search
        ElasticIndexerJob.perform(:index, self.class.to_s, id)
      end
    end

    def index_object_on_update
      if Rails.application.config.use_elastic_search
        if deleted? || try(:banned?)
          ElasticIndexerJob.perform(:delete, self.class.to_s, id)
        else
          ElasticIndexerJob.perform(:update, self.class.to_s, id)
        end
      end
    end

    def delete_from_index_on_destroy
      if Rails.application.config.use_elastic_search
        ElasticIndexerJob.perform(:delete, self.class.to_s, id)
      end
    end
  end
end
