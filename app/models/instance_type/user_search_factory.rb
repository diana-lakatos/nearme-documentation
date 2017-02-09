module InstanceType
  class UserSearchFactory
    attr_accessor :factory_type, :transactable_type, :params
    include SearcherHelper

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
    end

    def create
      InstanceType::Searcher::Elastic::UserSearcher.new(params, @current_user)
    end
  end
end
