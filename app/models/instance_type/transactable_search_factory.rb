# frozen_string_literal: true
module InstanceType
  class TransactableSearchFactory
    attr_accessor :factory_type, :transactable_type, :params
    include SearcherHelper

    def initialize(params, current_user = nil)
      @params = params
      @current_user = current_user
    end

    def create
      if result_view == 'mixed'
        location_searcher
      else
        listing_searcher
      end
    end

    def transactable_type
      find_transactable_type
      @transactable_type
    end

    private

    def result_view
      SearcherHelper::ResultView.new(params, transactable_type)
    end

    def search_module
      Instance::SEARCH_MODULES[factory_type] ? "::#{Instance::SEARCH_MODULES[factory_type]}" : ''
    end

    def location_searcher
      "InstanceType::Searcher#{search_module}::GeolocationSearcher::Location".constantize.new(transactable_type, params)
    end

    def listing_searcher
      searcher = "InstanceType::Searcher#{search_module}::GeolocationSearcher::Listing".constantize.new(transactable_type, params)
      searcher.invoke
      searcher
    end

    def factory_type
      @factory_type = transactable_type.search_engine
    end
  end
end
