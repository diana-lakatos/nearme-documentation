module Searching
  class ElasticSearchBased < Base
    include InstanceType::Searcher::Elastic::GeolocationSearcher
  end
end
