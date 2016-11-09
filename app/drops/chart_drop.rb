# frozen_string_literal: true
class ChartDrop < BaseDrop
  delegate :total, :money?, :collection, :chart_type, :empty?, :period, to: :source

  def values
    @source.values.to_json.html_safe
  end

  def labels
    @source.labels.to_json.html_safe
  end

  def no_result
    I18n.t('dashboard.analytics.no_results',
           type: I18n.t('dashboard.analytics.' + chart_type).downcase,
           period: I18n.t('dashboard.analytics.' + period))
  end
end
