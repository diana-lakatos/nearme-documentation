widget :listings_line do
  key "eb362fbe3940a0d8ef666e2850176c295de5ef84"
  type "line"
  data do
    widget_helper = WidgetHelper.new(Listing)
    widget_helper.get_line_data
  end
end
