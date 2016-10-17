class ChartDecorator < Draper::CollectionDecorator
  def initialize(collection, show_period = :last_7_days, options = {})
    @options = options.reverse_merge(labels_max_count: 10)
    @show_period = show_period
    super(collection, with: ChartItemDecorator)
  end

  def labels
    # Because of the width of chart, we have to limit size of labels to about 10.
    # If there are more labels to be shown, we just dont show these labels and show just empty strings instead.
    if dates.size <= @options[:labels_max_count]
      dates
    else
      Array.new(dates.size, '')
    end
  end

  def dates
    @dates ||= case @show_period
    when :last_7_days
      6.downto(0).map { |i| I18n.l((Time.zone.now - i.day).to_date, format: :day_and_month) }
    when :last_30_days
      30.downto(0).map { |i| I18n.l((Time.zone.now - i.day).to_date, format: :day_and_month) }
    else
      grouped_by_date.keys.sort
    end
  end

  def total
    sum = decorated_collection.sum(&:sum_by)
    sum.respond_to?(:amount) ? sum.amount : sum
  end

  def values
    result = dates.map do |date|
      sum = grouped_by_date[date] ? grouped_by_date[date].sum(&:sum_by) : 0
      sum.respond_to?(:amount) ? sum.amount : sum
    end
    [result]
  end

  # @return [Hash<String, Money>] hash containing the currency as keys
  #   and the sums for each currency as values
  def totals_by_currency
    hash = {}
    decorated_collection.group_by(&:currency).each do |currency, currency_values|
      hash[currency] = currency_values.sum(&:sum_by)
    end
    hash
  end

  def to_liquid
    @chart_drop ||= ChartDrop.new(self)
  end

  private

  def grouped_by_date
    @grouped_by_date ||= begin
      hash = {}
      decorated_collection.group_by(&:formatted_date).each do |date, date_values|
        hash[date] = date_values
      end
      hash
    end
  end
end
