module InstanceType
  class CommunitySearcherFactory
    attr_accessor :params, :search_type
    def initialize(params, current_user)
      @params = params
      @search_type = params[:search_type]
      @current_user = current_user
    end

    def create
      return people_searcher if search_type == 'people'

      community_searcher
    end

    private

    def people_searcher
      InstanceType::Searcher::UserSearcher.new(params, @current_user, InstanceProfileType.default.first)
    end

    def community_searcher
      "InstanceType::Searcher::#{params[:search_type].titleize}Searcher".constantize.new(params, @current_user)
    end
  end
end
