# frozen_string_literal: true
module InstanceType
  class CommunitySearcherFactory
    attr_accessor :params, :search_type
    def initialize(params, current_user)
      @params = params
      @search_type = params[:search_type]
      @current_user = current_user
    end

    def create
      case search_type
      when 'people' then people_searcher
      else
        community_searcher
      end
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
