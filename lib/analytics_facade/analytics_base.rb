# frozen_string_literal: true

class AnalyticsFacade::AnalyticsBase
  AGREGATION_CHARTS = %w(orders listings listing_views location_views).freeze
  MONEY_CHARTS = %w(revenue expenses transfers).freeze
  CHART_TYPES = MONEY_CHARTS + AGREGATION_CHARTS
  ADMIN_CHARTS = CHART_TYPES.except('expenses')

  DEFAULT_OPTIONS = {
    labels_max_count: 31,
    chart_type: 'revenue',
    period: 'last_7_days',
    page: 1,
    currency: 'USD'
  }.freeze

  attr_reader :scope, :options

  def initialize(scope, options)
    @scope = scope
    @options = options
  end

  def self.build(scope, options)
    @options = options.compact.reverse_merge(DEFAULT_OPTIONS)
    raise NotImplementedError unless CHART_TYPES.include?(@options[:chart_type])

    "AnalyticsFacade::#{@options[:chart_type].classify}Analytics".constantize.new(scope, @options)
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

  def values
    result = dates.map do |date|
      grouped_by_date[date] ? grouped_by_date[date].sum(&:chart_points) : 0
    end
    [result]
  end

  def chart_type
    @chart_type ||= @options[:chart_type]
  end

  def to_liquid
    @chart_drop ||= AnalyticsFacadeDrop.new(self)
  end

  def dates
    @dates ||= days_count.downto(0).map { |i| I18n.l((Time.zone.now - i.day).to_date, format: :day_and_month) }
  end

  def period
    @period ||= @options[:period]
  end

  def money?
    MONEY_CHARTS.include?(chart_type)
  end

  def empty?
    !chart_scope.any?
  end

  def list
    base_scope.order('created_at DESC').paginate(page: options[:page], per_page: 10)
  end

  def chart_scope
    base_scope.where(created_at: (Time.current.beginning_of_day - days_count.days)..Time.current)
  end

  def currency
    @currency ||= @options[:currency] || (currencies.include?('USD') ? 'USD' : currencies.first)
  end

  def currencies
    @currencies ||= money? ? collection.group(:currency).pluck(:currency) : []
  end

  private

  def grouped_by_date
    @grouped_by_date ||= begin
      hash = {}
      chart_data.group_by(&:chart_date).each do |date, date_values|
        hash[I18n.l(date.to_date, format: :day_and_month)] = date_values
      end
      hash
    end
  end

  def days_count
    @days_count ||= period == 'last_30_days' ? 30 : 6
  end
end
