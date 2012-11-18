class NullPriceRange < PriceRange
  def initialize
    super(0, 9999)
  end
end
