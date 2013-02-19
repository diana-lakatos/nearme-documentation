widget :users_line do
  key "f98f59e6c47042115fa09f75df9b002f72bd5ac5"
  type "line"
  data do
    widget_helper = WidgetHelper.new(User)
    widget_helper.get_line_data
  end
end
