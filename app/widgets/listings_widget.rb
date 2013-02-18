widget :listings do
  key "be07dbba46b16e9e1220146d9f65f68b83402376"
  type "number_and_secondary"
  data do
    widget_helper = WidgetHelper.new(Listing)
    {
      :value => widget_helper.get_count,
      :previous => widget_helper.get_secondary_count
    }
  end
end
