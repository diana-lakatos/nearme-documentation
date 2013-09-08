class WeeklyChartDecorator

  attr_accessor :grouped

  def initialize(collection)
    @collection = collection
    @grouped = group_collection
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
    @collection.group_by(&:currency).each do |currency, currency_values|
      hash[currency] = currency_values.sum(&:amount)
    end
    hash
  end

  private
  def group_collection
    hash = {}
    @collection.group_by(&:currency).each do |currency, currency_values|
      hash[currency] = currency_values.group_by{|v| formatted_date(v.created_at) }

      hash[currency].each do |date, date_values|
        hash[currency][date] = date_values.sum(&:"#{sum_by}")
      end
    end
    hash
  end

  def sum_by
    case @collection.table.name
    when 'reservation_charges'
      :total_amount
    when 'payment_transfers'
      :amount
    end
  end

  def formatted_date(datetime)
    datetime.strftime('%b %d')
  end

end
