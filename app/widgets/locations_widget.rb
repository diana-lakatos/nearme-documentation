widget :locations do
  key "be4ff3940e4faeadc4c82df3f2e514a8fca70c23"
  type "number_and_secondary"
  data do
    widget_helper = WidgetHelper.new(Location)
    {
      :value => widget_helper.get_count,
      :previous => widget_helper.get_secondary_count
    }
  end
end
