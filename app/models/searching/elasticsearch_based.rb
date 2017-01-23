module Searching
  class SqlBased < Base
    include InstanceType::Searcher::GeolocationSearcher
  end
end
