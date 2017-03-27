# frozen_string_literal: true
module SearchableType
  extend ActiveSupport::Concern

  included do
    after_update :create_es_index, if: ->(obj) { obj.searchable_changed? && obj.searchable }

    def update_es_mapping
      return unless Rails.application.config.use_elastic_search

      begin
        self.class::DEPENDENT_CLASS.set_es_mapping
        self.class::DEPENDENT_CLASS.indexer_helper.update_mapping!
      rescue StandardError => e
        MarketplaceLogger.error('ES Update Mapping Error', e.to_s, raise: false)
      end
    end

    def create_es_index
      return unless Rails.application.config.use_elastic_search

      self.class::DEPENDENT_CLASS.indexer_helper.create_base_index
      self.class::DEPENDENT_CLASS.indexer_helper.create_alias
      ElasticInstanceIndexerJob.perform(update_type: 'rebuild', only_classes: [self.class::DEPENDENT_CLASS.to_s])
    end
  end
end
