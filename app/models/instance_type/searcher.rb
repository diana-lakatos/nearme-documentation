module InstanceType::Searcher

  attr_reader :results, :transactable_type

  def result_count
    if self.class.to_s =~ /Elastic/
      @search_results_count
    else
      @result_count ||= results.distinct.all.count rescue results.distinct.to_a.count
    end
  end

  def max_price
    return 0 if results.empty?
    if results.first.is_a?(Spree::Product)
      @max_fixed_price ||= results.map{|r| r.try(:price).to_i}.max
    else
      if self.class.to_s =~ /Elastic/
        @max_fixed_price ||= results.map{|r| 
          if r.is_a?(Location)
            r.listings.maximum(:fixed_price_cents).to_f
          else
            r.try(:fixed_price_cents).to_f
          end
        }.max / 100
        @max_fixed_price > 0 ? @max_fixed_price + 1 : @max_fixed_price
      else
        @max_fixed_price ||= results.maximum(:fixed_price_cents).to_f / 100
        @max_fixed_price > 0 ? @max_fixed_price + 1 : @max_fixed_price
      end
    end
  end

  def paginate_results(page, per_page)
    @result_max_price ||= max_price
    page ||= 1
    @results = @results.paginate(page: page.to_i, per_page: per_page.to_i)
  end

end
