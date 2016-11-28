# frozen_string_literal: true
class AnalyticsFacadeDrop < BaseDrop
  # @!method total
  #   @return [Float] total amount for the entire period
  # @!method money?
  #   @return [Boolean] is it a money chart (e.g. revenue, expenses, transfers)
  # @!method list
  #   @return [Array<Object>] the underlying collection of charted data ordered by the time of creation
  #     (descending) and paginated (10 per page)
  # @!method chart_type
  #   @return [String] for what type of data we're charting (e.g. transfers, expenses, revenue)
  # @!method empty?
  #   @return [Boolean] whether there's no underlying data (no objects) for the selected period
  # @!method period
  #   @return [String] period for which we're charting (e.g. last_30_days)
  # @!method currencies
  #   @return [Array<String>] list of available currencies
  # @!method currency
  #   @return [String] currency for which chart was prepared
  delegate :total, :money?, :list, :chart_type, :empty?, :period,
           :currencies, :currency, to: :source

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

  # @return [String] no results text in the format (taken from the translation string 'dashboard.analytics.no_results')
  #   'No %{type} in last %{period}.' where type is 'dashboard.analytics.%{chart_type}' (chart_type e.g. transfers, expenses, revenue)
  #   and period is 'dashboard.analytics.%{period}' (period e.g. last_7_days, last_30_days)
  def no_result
    I18n.t('dashboard.analytics.no_results',
           type: I18n.t('dashboard.analytics.' + chart_type).downcase,
           period: I18n.t('dashboard.analytics.' + period))
  end
end
