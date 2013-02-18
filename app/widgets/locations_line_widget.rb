widget :locations_line do
  key "7468333051888c301a4f908a4cddc00c80a2d5d7"
  type "line"
  data do
    widget_helper = WidgetHelper.new(Location)
    widget_helper.get_line_data
  end
end
