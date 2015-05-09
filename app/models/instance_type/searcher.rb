module InstanceType::Searcher

  attr_reader :results, :transactable_type

  def result_count
    @result_count ||= count_query(results.distinct)
  end

  # Hack to get proper count from grouped querry
  def count_query(query)
    query = "SELECT count(*) AS count_all FROM (#{query.to_sql}) x"
    Spree::Product.count_by_sql(query)
  end

  def paginate_results(page, per_page)
    page ||= 1
    @results = @results.paginate(page: page, per_page: per_page)
  end

end
