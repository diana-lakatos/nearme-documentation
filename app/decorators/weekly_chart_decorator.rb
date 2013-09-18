class WeeklyChartDecorator < Draper::CollectionDecorator

  def initialize(collection)
    super(collection, with: WeeklyChartItemDecorator)
  end

  def labels
    @labels ||= 6.downto(0).map { |i| formatted_date(Time.zone.now - i.day) }
  end

  def values
    grouped.map do |currency, dates|
      labels.map do |label_date|
        dates[label_date].try(:amount) || 0
      end
    end
  end

  def sums_by_currency
    hash = {}
    decorated_collection.group_by(&:currency).each do |currency, currency_values|
      hash[currency] = currency_values.sum(&:amount)
    end
    hash
  end

  private
  def grouped
    @grouped ||= begin
      hash = {}
      decorated_collection.group_by(&:currency).each do |currency, currency_values|
        hash[currency] = currency_values.group_by{|v| v.formatted_date }

        hash[currency].each do |date, date_values|
          hash[currency][date] = date_values.sum(&:sum_by)
        end
      end
      hash
    end
  end

  def formatted_date(datetime)
    datetime.strftime('%b %d')
  end

end
