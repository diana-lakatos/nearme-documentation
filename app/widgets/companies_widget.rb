widget :companies do
  key "6b5d25d053aaf3c14583580589872f6b969cc439"
  type "number_and_secondary"
  data do
    widget_helper = WidgetHelper.new(Company)
    {
      :value => widget_helper.get_count,
      :previous => widget_helper.get_secondary_count
    }
  end
end
