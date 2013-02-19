widget :users do
  key "43b81af607b3ee6d11d7ddd66f1df867cc4eedff"
  type "number_and_secondary"
  data do
    widget_helper = WidgetHelper.new(User)
    {
      :value => widget_helper.get_count,
      :previous => widget_helper.get_secondary_count
    }
  end
end
