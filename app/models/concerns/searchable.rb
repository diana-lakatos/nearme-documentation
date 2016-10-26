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
      if PlatformContext.current.try(:instance) && PlatformContext.current.instance.search_settings['use_individual_index'] == 'true'
        "#{to_s.demodulize.pluralize.downcase}-#{Rails.env}-#{PlatformContext.current.try(:instance).try(:id)}"
      else
        to_s.demodulize.pluralize.downcase.to_s
      end
    end

    def self.update_mapping!
      __elasticsearch__.client.indices.put_mapping index: index_name, type: to_s.demodulize.downcase.to_s, body: mappings
    end
  end
end
