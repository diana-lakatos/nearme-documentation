# frozen_string_literal: true
module Searching
  class ElasticSearchBased < Base
    include InstanceType::Searcher::Elastic::GeolocationSearcher

    def object
      transactable_type
    end
  end
end
