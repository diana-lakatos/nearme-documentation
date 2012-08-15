class Array

  # returns a nested Array of elements by rank, allowing for even "scores"
  # the proc should return a "score" to rank by
  # [ [elements with score = x], [element with score = x + 1], [ elements with score = x + 2 ], ... ]
  def rank_by(&proc)
    # NB: This is hilariously similar to ActiveSupport's Enumerable#group_by...
    # should we just use that code? (better battle-tested)
    # sort.group_by(&proc).map(&:last)
    # http://api.rubyonrails.org/classes/Enumerable.html#method-i-group_by
    self.inject({}) do |hsh, element|
      score = proc.call(element)
      hsh[score] ||= []
      hsh[score] << element
      hsh
    end.sort.map(&:last)
  end

end