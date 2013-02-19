widget :reservations do
  key "b650e023a4c8c4a348d2dad4574b2c7a6027f7e3"
  type "number_and_secondary"
  data do
    widget_helper = WidgetHelper.new(Reservation)
    {
      :value => widget_helper.get_count,
      :previous => widget_helper.get_secondary_count
    }
  end
end
