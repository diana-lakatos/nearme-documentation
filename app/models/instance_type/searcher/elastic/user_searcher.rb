class InstanceType::Searcher::Elastic::UserSearcher
  ALLOWED_QUERY_FIELDS = [:first_name, :last_name, :name, :country_name, :company_name, :tags].freeze

  include InstanceType::Searcher

  attr_reader :filterable_custom_attributes, :search

  def initialize(params, current_user)
    @current_user = current_user
    @params = params
    @instance_profile_type = PlatformContext.current.instance.instance_profile_types.searchable.first
  end

  def fetcher
    @fetcher ||= User
                   .regular_search(search_params, @instance_profile_type)
                   .paginate(page: @params[:page], per_page: @params[:per_page])
  end

  def object
    @instance_profile_type
  end

  def searchable_categories
    @instance_profile_type.categories.searchable.roots.includes(children: { children: :children })
  end

  def search_form
    @search ||= ::User::Search::Params::Web.new(@params, @instance_profile_type, fetcher.aggregations)
  end

  def search_query_values
    { query: @params[:query] }
  end

  def results
    @results ||= ElasticCollectionProxy.new(fetcher.results)
  end

  def result_view
    'list'
  end

  # we need this wrapper because of elasticsearch-model results immutable implementation
  class ElasticCollectionProxy < SimpleDelegator
    delegate :each, :map, to: :results

    def results
      __getobj__.results.map { |u| u.extend(Liquidable) }
    end

    module Liquidable
      def to_liquid
        Elastic::UserDrop.new(_source)
      end
    end
  end

  private

  def search_params
    default_search_params.merge sort: (@params[:sort].presence || 'relevance').inquiry
  end

  def default_search_params
    @params.merge instance_id: PlatformContext.current.instance.id
  end
end
