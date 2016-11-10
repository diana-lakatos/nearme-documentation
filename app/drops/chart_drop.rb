class ChartDrop < BaseDrop
  # @!method totals_by_currency
  #   @return [Hash<String, MoneyDrop>] hash containing the currency as keys
  #     and the sums for each currency as values
  delegate :totals_by_currency, to: :source

  # @return [String] string of chart values in JSON format
  #   of the form "[[1,6,7,10]]"
  def values
    @source.values.to_json.html_safe
  end

  # @return [String] string of chart labels in JSON format
  #   of the form "['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15']"
  def labels
    @source.labels.to_json.html_safe
  end
end
