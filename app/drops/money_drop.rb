class MoneyDrop < BaseDrop

  # @!method currency
  #   @return [Money::Currency] currency for the money instance
  # @!method fractional
  #   @return [Integer] the value of the monetary amount represented in the fractional or subunit of the currency
  # @!method amount
  #   @return [BigDecimal] the numerical value of the money
  # @!method cents
  #   @return (see MoneyDrop#fractional)
  # @!method dollars
  #   @return [BigDecimal] assuming using a currency using dollars: 
  #     returns the value of the money in dollars, instead of in the fractional unit cents.
  # @!method to_money
  #   @return [Money] conversion to self
  # @!method to_i
  #   @return [Integer] the amount of money as an integer
  # @!method to_f
  #   @return [Float] the amount of money as a float
  delegate :currency, :fractional, :amount, :cents, :dollars, :to_money, :to_i, :to_f, to: :source

  # @return [String] the numerical value of the money as a string
  def to_s
    @source.amount
  end
end
