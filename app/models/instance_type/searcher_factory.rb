# frozen_string_literal: true
module InstanceType
  class SearcherFactory
    def self.community?
      PlatformContext.current.instance.is_community?
    end

    def self.search_type(params)
      return 'community' if community?

      params[:search_type]
    end

    def self.create(params, current_user)
      case search_type(params)

      when 'community'
        CommunitySearcherFactory.new(params, current_user).create

      when 'people'
        UserSearchFactory.new(params, current_user).create

      else
        TransactableSearchFactory.new(params, current_user).create
      end
    end
  end
end
