class InstanceType::Searcher::Elastic::UserSearcher
  ALLOWED_QUERY_FIELDS = [:first_name, :last_name, :name, :country_name, :company_name, :tags].freeze

  include InstanceType::Searcher

  attr_reader :filterable_custom_attributes, :search

  def initialize(params, current_user, instance_profile_type)
    @current_user = current_user
    @params = params
    @instance_profile_type = instance_profile_type
  end

  def fetcher
    @fetcher ||= User.regular_search(search_params, @instance_profile_type)
  end

  def searchable_categories
    @instance_profile_type.categories.searchable.roots.includes(children: { children: :children })
  end

  def search
    @search ||= ::User::Search::Params::Web.new(@params, @instance_profile_type)
  end

  def search_query_values
    { query: @params[:query] }
  end

  # page-page and page for ES and PG are not the same thing
  # when paging PG results based on ES search we take only first page
  def results
    @results ||= append_es_data user_collection
  end

  def append_es_data(users)
    users.each do |user|
      es_data = find_es_user(user.id)

      user.extend(UserDAO)
      user.append_data es_data, @instance_profile_type.profile_type
    end

    users
  end

  def find_es_user(id)
    @fetcher.results.find { |item| item.id.to_i == id }
  end

  # first iteration
  # combine results from ES and DB
  module UserDAO
    def append_data(data, profile_type)
      @__data = data
      @__profile_type = profile_type
    end

    def category_ids
      __profile.category_ids
    end

    def buyer_properties
      __profile.properties
    end

    def tag_list
      @tag_list ||= __source.tags.split(',')
    end

    # do not decorate decorated decorator
    def decorate
      self
    end

    def to_liquid
      @user_drop ||= UserDrop.new(self)
    end

    private

    def __profile
      __source.user_profiles.find { |p| p.profile_type == @__profile_type }
    end

    def __source
      @__data._source
    end
  end

  private

  def search_params
    default_search_params.merge sort: (@params[:sort].presence || 'relevance').inquiry,
                                limit: @params[:per_page],
                                page: @params[:page]
  end

  def default_search_params
    @params.merge instance_id: PlatformContext.current.instance.id,
                  instance_profile_type_id: @instance_profile_type.id
  end

  def user_collection
    User
      .where(id: user_ids)
      .includes(:current_address, :blog)
      .not_admin
      .order_by_array_of_ids(user_ids)
      .paginate(page: @params[:page], per_page: @params[:per_page], total_entries: @fetcher.results.total)
      .offset(0)
  end

  def user_ids
    @user_ids = fetcher.map(&:id)
  end
end
