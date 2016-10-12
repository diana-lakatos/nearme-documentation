class ChartDrop < BaseDrop
  delegate :totals_by_currency, to: :source

  def values
    @source.values.to_json.html_safe
  end

  def labels
    @source.labels.to_json.html_safe
  end
end
