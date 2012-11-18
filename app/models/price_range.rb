class PriceRange < Struct.new(:min, :max)
  MAX_SEARCHABLE_PRICE = 300

  def initialize(min, max)
    max = 9999 if max.nil? || max.to_i > MAX_SEARCHABLE_PRICE
    super(min.to_i, max.to_i)
  end

  def min_cents
    min * 100
  end

  def max_cents
    max * 100
  end

  def midpoint_cents
    (max_cents + min_cents) / 2
  end

  def include_cents?(cents = 0)
    (min_cents..max_cents).cover?(cents)
  end

end
