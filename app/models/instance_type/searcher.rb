module InstanceType::Searcher

  attr_reader :results, :transactable_type

  def result_count
    if self.class.to_s =~ /Elastic/
      @search_results_count
    else
      @result_count ||= count_query(results.distinct)
    end
  end

  # Hack to get proper count from grouped querry
  def count_query(query)
    query = "SELECT count(*) AS count_all FROM (#{query.to_sql}) x"
    Spree::Product.count_by_sql(query)
  end

  def max_price
    begin
      @max_fixed_price ||= results.maximum(:fixed_price_cents).to_f / 100
      @max_fixed_price > 0 ? @max_fixed_price + 1 : @max_fixed_price
    rescue
      max_price = 0
      results.each{|r| max_price = r.price if r.try(:price).to_i > max_price}
      @max_fixed_price ||= max_price
    end
  end

  def paginate_results(page, per_page)
    @result_max_price ||= max_price
    page ||= 1
    result_count
    @results = @results.paginate(page: page.to_i, per_page: per_page.to_i)
  end

end
