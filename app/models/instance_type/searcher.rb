module InstanceType::Searcher

  attr_reader :results, :transactable_type

  def result_count
    @result_count ||= results.distinct.count
  end

  def paginate_results(page, per_page)
    page ||= 1
    @results = @results.paginate(page: page, per_page: per_page)
  end

end
