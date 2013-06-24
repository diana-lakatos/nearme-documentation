class StringMatcher

  def initialize(keys, values)
    @keys = keys
    @values = values
  end

  def create_pairs
    # first, be optimistic and find best match for each string
    @keys.inject({}) do |pairs, string|
      pairs[string] = find_best_matches(string, @values) 
      pairs
    end
  end

  def find_best_matches(string, possibilities_array)
    result = possibilities_array.inject({:coefficient => 0, :matches => [] }) do |best_matches, possibility|
      # http://stackoverflow.com/questions/653157/a-better-similarity-ranking-algorithm-for-variable-length-strings#answer-13617369, used amatch gem
      coefficient = string.downcase.pair_distance_similar(possibility.downcase)
      if coefficient > best_matches[:coefficient]
        best_matches[:coefficient] = coefficient
        best_matches[:matches] = [possibility]
      elsif coefficient == best_matches[:coefficient]
        best_matches[:matches] << possibility
      end
      best_matches
    end
    result[:coefficient] > 0.1 ? result[:matches] : []
  end

end
