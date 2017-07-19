# frozen_string_literal: true
require './lib/elastic' # rails dev env needs this

module Searchable
  extend ActiveSupport::Concern

  included do
    include QuerySearchable
    include Elasticsearch::Model
    include "#{to_s.demodulize.pluralize}Index".constantize
    include ResetMapping

    after_commit :refresh_index

    index_name -> { Elastic.index_for(PlatformContext.current.instance).index_name }

    scope :indexable, -> { with_deleted }

    private

    def refresh_index
      if transaction_include_any_action? [:create, :update]
        ElasticIndexerJob.perform(:index, self.class.to_s, id)

      elsif transaction_include_any_action? [:delete]
        ElasticIndexerJob.perform(:delete, self.class.to_s, id)
      end
    end
  end
end
