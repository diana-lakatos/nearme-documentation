widget :reservations_line do
  key "b4edd558d4274d32668558635c43e396c075bae1"
  type "line"
  data do
    widget_helper = WidgetHelper.new(Reservation)
    widget_helper.get_line_data
  end
end
