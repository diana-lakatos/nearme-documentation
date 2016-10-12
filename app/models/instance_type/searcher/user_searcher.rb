class InstanceType::Searcher::UserSearcher
  include InstanceType::Searcher
  attr_reader :filterable_custom_attributes, :search
  ALLOWED_QUERY_FIELDS = [:first_name, :last_name, :name, :country_name, :company_name, :tags].freeze

  def initialize(params, current_user, transactable_type)
    @current_user = current_user
    @params = params
    @transactable_type = transactable_type
    @results = fetcher.not_admin
    set_options_for_filters
  end

  def fetcher
    @fetcher = @transactable_type.users.search_by_query(queried_fields, @params[:query])
    @fetcher = @fetcher.by_topic(selected_values(:topic_ids)).custom_order(@params[:sort], @current_user)
    @fetcher = @fetcher.filtered_by_role(selected_values(:role))
    @fetcher = @fetcher.buyers if @params[:profile_type] == 'buyer'
    @fetcher = @fetcher.sellers if @params[:profile_type] == 'seller'
    @fetcher = @fetcher.with_enabled_profile(@transactable_type.id) if @transactable_type.search_only_enabled_profiles?
    @fetcher.includes(:current_address)

    (@params[:lg_custom_attributes] || {}).each do |field_name, values|
      values = Array(values).reject(&:blank?)
      next if values.empty?

      @fetcher = @fetcher.filtered_by_custom_attribute(field_name, values.join(','))
    end

    if @params[:category_ids].present?
      category_ids = @params[:category_ids].split(',')

      if @transactable_type.category_search_type == 'AND'
        @fetcher = @fetcher.where("(select count(*) from categories_categorizables cc
          WHERE cc.categorizable_type = 'UserProfile' AND cc.categorizable_id = user_profiles.id
          AND cc.category_id in (?)) = ?", category_ids, category_ids.size)
      else
        @fetcher = @fetcher.joins("INNER JOIN categories_categorizables cc ON
          cc.categorizable_type = 'UserProfile' AND cc.categorizable_id = user_profiles.id")
                   .where('cc.category_id in (?)', category_ids)
      end
    end

    @fetcher
  end

  def topics_for_filter
    fetcher.map(&:topics).flatten.uniq
  end

  def selected_values(name)
    @params[name].select(&:present?) if @params[name]
  end

  def queried_fields
    queried_fields = [:first_name, :last_name, :name]
    if @params[:query_fields].present?
      params_fields = @params[:query_fields].split(',').map(&:to_sym)
      params_fields.select! { |field| (ALLOWED_QUERY_FIELDS + @transactable_type.custom_attributes.searchable.pluck(:name).map(&:to_sym)).include?(field) }
      queried_fields + params_fields
    else
      queried_fields
    end
  end

  def search_query_values
    {
      query: @params[:query]
    }.merge(filters)
  end

  def filters
    search_filters = {}
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters[:category_ids] = @params[:category_ids] unless @params[:category_ids].blank?
    search_filters
  end

  def search
    @search ||= ::Listing::Search::Params::Web.new(@params, @transactable_type)
  end

  def set_options_for_filters
    @filterable_custom_attributes = @transactable_type.custom_attributes.searchable
  end

  def to_event_params
    { search_query: query, result_count: result_count }
  end
end
