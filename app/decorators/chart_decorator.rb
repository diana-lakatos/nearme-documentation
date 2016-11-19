# frozen_string_literal: true
class ChartDecorator < Draper::CollectionDecorator
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

  def initialize(scope, options)
    # Instance or Company scope - defines reference point for stats
    @scope = scope
    @options = options.compact.reverse_merge(DEFAULT_OPTIONS)

    raise NotImplementedError unless CHART_TYPES.include?(chart_type)

    @scope = send("prepare_#{chart_type}_data")
  end

  def chart_type
    @chart_type ||= @options[:chart_type]
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
    @dates ||= days_count.downto(0).map { |i| I18n.l((Time.zone.now - i.day).to_date, format: :day_and_month) }
  end

  def values
    result = dates.map do |date|
      grouped_by_date[date] ? grouped_by_date[date].sum(&:chart_points) : 0
    end
    [result]
  end

  def total
    points = chart_data.map(&:chart_points).sum
    money? ? points.to_money(currency) : points
  end

  def money?
    MONEY_CHARTS.include?(chart_type)
  end

  def empty?
    !@scope.last_x_days(days_count).any?
  end

  def collection
    @scope.order('created_at DESC').paginate(page: @options[:page], per_page: 10)
  end

  def to_liquid
    @chart_drop ||= ChartDrop.new(self)
  end

  def period
    @period ||= @options[:period]
  end

  private

  def grouped_by_date
    @grouped_by_date ||= begin
      hash = {}
      chart_data.last_x_days(days_count).group_by(&:chart_date).each do |date, date_values|
        hash[I18n.l(date.to_date, format: :day_and_month)] = date_values
      end
      hash
    end
  end

  def prepare_listings_data
    @scope.listings
  end

  def prepare_expenses_data
    new_scope = @scope.creator.payments.paid.where(currency: currency)
    new_scope = new_scope.where(payment_transfer_id: @options[:payment_transfer_id]) if @options[:payment_transfer_id]
    new_scope
  end

  def prepare_revenue_data
    new_scope = @scope.payments.paid.where(currency: currency)
    new_scope = new_scope.where(payment_transfer_id: @options[:payment_transfer_id]) if @options[:payment_transfer_id]
    new_scope
  end

  def prepare_orders_data
    @scope.orders
  end

  def prepare_listing_views_data
    @scope.listings_impressions
  end

  def prepare_transfers_data
    @scope.payment_transfers.where(currency: currency)
  end

  def prepare_location_views_data
    @scope.locations_impressions
  end

  def chart_data
    @scope.select(
      "(#{collection_table}.created_at::timestamp at time zone \'#{Time.zone}\')::DATE AS chart_date, #{agregate_with} as chart_points"
    ).group('chart_date').order('chart_date ASC')
  end

  def agregate_with
    case chart_type
    when 'transfers' then 'sum(amount_cents) / 100'
    when 'revenue', 'expenses' then 'sum(total_amount_cents) / 100'
    else
      'count(*)'
    end
  end

  def collection_table
    @scope.table.name
  end

  def currency
    @currency ||= @options[:currency]
  end

  def days_count
    @days_count ||= @period == 'last_30_days' ? 30 : 6
  end
end
