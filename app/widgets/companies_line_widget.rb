widget :companies_line do
  key "842af3577029884eb7d747e63275d2a455e2ed1a"
  type "line"
  data do
    widget_helper = WidgetHelper.new(Company)
    widget_helper.get_line_data
  end
end
