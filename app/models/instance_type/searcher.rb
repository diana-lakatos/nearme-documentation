module InstanceType::Searcher

  attr_reader :results

  def result_count
    @result_count ||= results.count
  end

  def paginate_results(page, per_page)
    page ||= 1
    @results = WillPaginate::Collection.create(page, per_page, result_count) do |pager|
      pager.replace(results[pager.offset, pager.per_page].to_a)
    end
  end

end
