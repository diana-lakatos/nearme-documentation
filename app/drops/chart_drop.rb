# frozen_string_literal: true
class ChartDrop < BaseDrop
  delegate :total, :money?, :collection, :chart_type, :empty?, :period, to: :source

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

  def no_result
    I18n.t('dashboard.analytics.no_results',
           type: I18n.t('dashboard.analytics.' + chart_type).downcase,
           period: I18n.t('dashboard.analytics.' + period))
  end
end
